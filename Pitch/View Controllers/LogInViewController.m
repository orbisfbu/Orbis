//
//  LogInViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/24/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "FirebaseDatabase/FirebaseDatabase.h"
#import "AppDelegate.h"
#import "LogInViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FBSDKLoginManagerLoginResult.h"
#import <FBSDKAccessToken.h>
#import "MasterViewController.h"
#import "DataHandling.h"

//Fields to be used when saving user to database
static NSString * const DATABASE_USER_NODE = @"Users";
static NSString * const USER_FIRSTNAME = @"First Name";
static NSString * const USER_LASTNAME = @"Last Name";
static NSString * const USER_EMAIL = @"Email";
static NSString * const USER_PROFILE_IMAGE_URLSTRING = @"Profile Image";
//Required permissions for user info
static NSString * const PUBLIC_PROFILE_PERMISSION = @"public_profile";
static NSString * const EMAIL_PERSMISSION = @"email";

//Debugging/Error Messages
static NSString * const SUCCESSFUL_USER_SAVE = @"Successfully saved User info to database";
static NSString * const SIGN_OUT_FAILURE = @"Error occured while signing out";
static NSString * const AUTHENTICATION_ERROR = @"Error occured while authenticating user";
static NSString * const DATA_FETCH_ERROR = @"An error occured while retrieving User profile image";

// Constant View Names
static NSString * const CONTINUE_VIEW = @"CONTINUE_VIEW";
static NSString * const SIGNIN_VIEW = @"SIGNIN_VIEW";
static NSString * const SIGNUP_VIEW1 = @"SIGNUP_VIEW1";
static NSString * const SIGNUP_VIEW2 = @"SIGNUP_VIEW2";

@interface LogInViewController () <FBSDKLoginButtonDelegate, ShowLoginScreenDelegate>

//inputted properties to be used and checked during
//the welcoming process; will have to check whether or not
//initially inputted email and password correspond to existing account
@property (strong, nonatomic) NSString *inputtedUserEmail;
@property (strong, nonatomic) NSString *inputtedPassword;
//these registering properties are to be set if inputted email doesn't
//correspond to an account
@property (strong, nonatomic) NSString *registerFirstName;
@property (strong, nonatomic) NSString *registerLastName;
@property (strong, nonatomic) NSString *registerUsername;
//for the password confirm field later on, just make sure that
//the text of that cofirm password field is the same registerPassword
@property (strong, nonatomic) NSString *registerPassword;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) FBSDKLoginButton *FBLoginButton;

// To keep track of what screen we are on
@property (strong, nonatomic) NSString *viewName;

// For continue screen
@property (strong, nonatomic) UILabel *welcomeLabel1;
@property (strong, nonatomic) UILabel *welcomeLabel2;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UILabel *orLabel;

// For login screen
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *logInButton;

// For signup screen 1
@property (strong, nonatomic) UITextField *firstNameTextField;
@property (strong, nonatomic) UITextField *lastNameTextField;
@property (strong, nonatomic) UIButton *nextButton;

// For signup screen 2
@property (strong, nonatomic) UITextField *usernameSignUpTextField;
@property (strong, nonatomic) UITextField *passwordSignUpTextField;
@property (strong, nonatomic) UITextField *confirmPasswordSignUpTextField;
@property (strong, nonatomic) UIButton *signUpButton;
@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backButton setEnabled:NO];
    self.backButton.alpha = 0;
    
    if (![FIRAuth auth].currentUser) {
        NSLog(@"No user signed in... Creating sign in/up page");
        [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.FBLoginButton.delegate = self;
        self.FBLoginButton.permissions = @[PUBLIC_PROFILE_PERMISSION, EMAIL_PERSMISSION];
        // Add touch gestures to dismiss keyboard
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:tapGesture];
        [self createPageObjects];
        [self createContinuePage];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([FIRAuth auth].currentUser) {
        NSLog(@"User was already logged in... Creating user profile");
        [self segueToApp];
    }
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) createPageObjects {
    // Add welcome labels
    self.welcomeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(30, self.view.frame.size.height, 400, 200)];
    [self.welcomeLabel1 setText:@"Welcome"];
    [self.welcomeLabel1 setFont:[UIFont fontWithName:@"arial-boldmt" size:75]];
    [self.welcomeLabel1 sizeToFit];
    [self.welcomeLabel1 setRestorationIdentifier:@"welcomeLabel1"];
    [self.view addSubview:self.welcomeLabel1];
    self.welcomeLabel2 = [[UILabel alloc] initWithFrame: CGRectMake(30, self.view.frame.size.height, 400, 200)];
    [self.welcomeLabel2 setText:@"to Pitch!"];
    [self.welcomeLabel2 setFont:[UIFont fontWithName:@"arial-boldmt" size:75]];
    [self.welcomeLabel2 sizeToFit];
    [self.welcomeLabel2 setRestorationIdentifier:@"welcomeLabel2"];
    [self.view addSubview:self.welcomeLabel2];
    
    // Add email text field
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.emailTextField setPlaceholder:@"email"];
    [self.emailTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.emailTextField];
    
    // Add continue button
    self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.continueButton setBackgroundColor:[UIColor blackColor]];
    self.continueButton.layer.cornerRadius = 5;
    [self.continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.continueButton];
    
    // Add --OR-- label
    self.orLabel = [[UILabel alloc] initWithFrame: CGRectMake(30, self.view.frame.size.height, 100, 30)];
    [self.orLabel setFont:[UIFont fontWithName:@"roboto" size:20]];
    [self.orLabel setText:@"-- OR --"];
    [self.orLabel sizeToFit];
    [self.orLabel setCenter:CGPointMake(self.view.center.x, self.orLabel.center.y)];
    [self.view addSubview:self.orLabel];
    
    // Add continue with facebook button
    self.FBLoginButton = [[FBSDKLoginButton alloc] initWithFrame: CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.view addSubview:self.FBLoginButton];
    
    // Add username text field
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.usernameTextField setPlaceholder:@"Username"];
    [self.usernameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.usernameTextField];
    
    // Add password text field
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.passwordTextField setPlaceholder:@"Password"];
    [self.passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.passwordTextField];
    
    // Add login button
    self.logInButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.logInButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.logInButton setBackgroundColor:[UIColor blackColor]];
    self.logInButton.layer.cornerRadius = 5;
    [self.logInButton addTarget:self action:@selector(logInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logInButton];
    
    // Add first name text field
    self.firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.firstNameTextField setPlaceholder:@"First/Preferred Name"];
    [self.firstNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.firstNameTextField];
    
    // Add last name text field
    self.lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.lastNameTextField setPlaceholder:@"Last Name"];
    [self.lastNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.lastNameTextField];
    
    // Add next button
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setBackgroundColor:[UIColor blackColor]];
    self.nextButton.layer.cornerRadius = 5;
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    // Add signup username text field
    self.usernameSignUpTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.usernameSignUpTextField setPlaceholder:@"Username"];
    [self.usernameSignUpTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.usernameSignUpTextField];
    
    // Add signup password text field
    self.passwordSignUpTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.passwordSignUpTextField setPlaceholder:@"Password"];
    [self.passwordSignUpTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.passwordSignUpTextField];
    
    // Add signup confirm password text field
    self.confirmPasswordSignUpTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.confirmPasswordSignUpTextField setPlaceholder:@"Confirm Password"];
    [self.confirmPasswordSignUpTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.confirmPasswordSignUpTextField];
    
    // Add signup button
    self.signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpButton setBackgroundColor:[UIColor blackColor]];
    self.signUpButton.layer.cornerRadius = 5;
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signUpButton];
}

- (void) segueToApp {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MasterViewController * vc = (MasterViewController *)[sb instantiateViewControllerWithIdentifier:@"MasterViewController"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) createContinuePage {
    self.viewName = CONTINUE_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.welcomeLabel1.frame = CGRectMake(30, 100, 400, 100);
        self.welcomeLabel2.frame = CGRectMake(30, self.welcomeLabel1.frame.origin.y + self.welcomeLabel1.frame.size.height, 400, 100);
        self.emailTextField.frame = CGRectMake(30, self.welcomeLabel2.frame.origin.y + self.welcomeLabel2.frame.size.height + 20, self.view.frame.size.width - 60, 30);
        self.continueButton.frame = CGRectMake(30, self.emailTextField.frame.origin.y + self.emailTextField.frame.size.height + 20, self.view.frame.size.width - 60, 30);
        self.orLabel.frame = CGRectMake(self.view.frame.size.width/2 - 30, self.continueButton.frame.origin.y + self.continueButton.frame.size.height + 20, 100, 30);
        self.FBLoginButton.frame = CGRectMake(30, self.orLabel.frame.origin.y + self.orLabel.frame.size.height + 20, self.view.frame.size.width - 60, 30);
    }];
}

- (void) dismissContinuePage {
    [UIView animateWithDuration:0.5 animations:^{
        self.welcomeLabel1.frame = CGRectMake(self.welcomeLabel1.frame.origin.x, -self.welcomeLabel1.frame.size.height, self.welcomeLabel1.frame.size.width, self.welcomeLabel1.frame.size.height);
        self.welcomeLabel2.frame = CGRectMake(self.welcomeLabel2.frame.origin.x, -self.welcomeLabel2.frame.size.height, self.welcomeLabel2.frame.size.width, self.welcomeLabel2.frame.size.height);
        self.emailTextField.frame = CGRectMake(self.emailTextField.frame.origin.x, -self.emailTextField.frame.size.height, self.emailTextField.frame.size.width, self.emailTextField.frame.size.height);
        self.continueButton.frame = CGRectMake(self.continueButton.frame.origin.x, -self.continueButton.frame.size.height, self.continueButton.frame.size.width, self.continueButton.frame.size.height);
        self.orLabel.frame = CGRectMake(self.orLabel.frame.origin.x, -self.orLabel.frame.size.height, self.orLabel.frame.size.width, self.orLabel.frame.size.height);
        self.FBLoginButton.frame = CGRectMake(self.FBLoginButton.frame.origin.x, -self.FBLoginButton.frame.size.height, self.FBLoginButton.frame.size.width, self.FBLoginButton.frame.size.height);
        self.backButton.alpha = 1;
    } completion:^(BOOL finished) {
        self.welcomeLabel1.frame = CGRectMake(self.welcomeLabel1.frame.origin.x, self.view.frame.size.height, self.welcomeLabel1.frame.size.width, self.welcomeLabel1.frame.size.height);
        self.welcomeLabel2.frame = CGRectMake(self.welcomeLabel2.frame.origin.x, self.view.frame.size.height, self.welcomeLabel2.frame.size.width, self.welcomeLabel2.frame.size.height);
        self.emailTextField.frame = CGRectMake(self.emailTextField.frame.origin.x, self.view.frame.size.height, self.emailTextField.frame.size.width, self.emailTextField.frame.size.height);
        self.continueButton.frame = CGRectMake(self.continueButton.frame.origin.x, self.view.frame.size.height, self.continueButton.frame.size.width, self.continueButton.frame.size.height);
        self.orLabel.frame = CGRectMake(self.orLabel.frame.origin.x, self.view.frame.size.height, self.orLabel.frame.size.width, self.orLabel.frame.size.height);
        self.FBLoginButton.frame = CGRectMake(self.FBLoginButton.frame.origin.x, self.view.frame.size.height, self.FBLoginButton.frame.size.width, self.FBLoginButton.frame.size.height);
    }];
}

- (void) createSignInPage {
    [self.backButton setEnabled:YES];
    self.viewName = SIGNIN_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.usernameTextField.frame = CGRectMake(self.usernameTextField.frame.origin.x, 100, self.usernameTextField.frame.size.width, self.usernameTextField.frame.size.height);
        self.passwordTextField.frame = CGRectMake(self.passwordTextField.frame.origin.x, self.usernameTextField.frame.origin.y + + self.usernameTextField.frame.size.height + 20, self.passwordTextField.frame.size.width, self.passwordTextField.frame.size.height);
        self.logInButton.frame = CGRectMake(self.logInButton.frame.origin.x, self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height + 20, self.logInButton.frame.size.width, self.logInButton.frame.size.height);
    }];
}

- (void) dismissSignInPage {
    [self.backButton setEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.usernameTextField.frame = CGRectMake(self.usernameTextField.frame.origin.x, -self.usernameTextField.frame.size.height, self.usernameTextField.frame.size.width, self.usernameTextField.frame.size.height);
        self.passwordTextField.frame = CGRectMake(self.passwordTextField.frame.origin.x, -self.passwordTextField.frame.size.height, self.passwordTextField.frame.size.width, self.passwordTextField.frame.size.height);
        self.logInButton.frame = CGRectMake(self.logInButton.frame.origin.x, -self.logInButton.frame.size.height, self.logInButton.frame.size.width, self.logInButton.frame.size.height);
        self.backButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.usernameTextField.frame = CGRectMake(self.usernameTextField.frame.origin.x, self.view.frame.size.height, self.usernameTextField.frame.size.width, self.usernameTextField.frame.size.height);
        self.passwordTextField.frame = CGRectMake(self.passwordTextField.frame.origin.x, self.view.frame.size.height, self.passwordTextField.frame.size.width, self.passwordTextField.frame.size.height);
        self.logInButton.frame = CGRectMake(self.logInButton.frame.origin.x, self.view.frame.size.height, self.logInButton.frame.size.width, self.logInButton.frame.size.height);
    }];
}

- (void) createSignUpPage1 {
    [self.backButton setEnabled:YES];
    self.viewName = SIGNUP_VIEW1;
    [UIView animateWithDuration:0.5 animations:^{
        self.firstNameTextField.frame = CGRectMake(self.firstNameTextField.frame.origin.x, 100, self.firstNameTextField.frame.size.width, self.firstNameTextField.frame.size.height);
        self.lastNameTextField.frame = CGRectMake(self.lastNameTextField.frame.origin.x, self.firstNameTextField.frame.origin.y + self.firstNameTextField.frame.size.height + 20, self.lastNameTextField.frame.size.width, self.lastNameTextField.frame.size.height);
        self.nextButton.frame = CGRectMake(self.nextButton.frame.origin.x, self.lastNameTextField.frame.origin.y + self.lastNameTextField.frame.size.height + 20, self.nextButton.frame.size.width, self.nextButton.frame.size.height);
    }];
}

- (void) dismissSignUpPage1:(BOOL)advancing {
    [UIView animateWithDuration:0.5 animations:^{
        self.firstNameTextField.frame = CGRectMake(self.firstNameTextField.frame.origin.x, -self.firstNameTextField.frame.size.height, self.firstNameTextField.frame.size.width, self.firstNameTextField.frame.size.height);
        self.lastNameTextField.frame = CGRectMake(self.lastNameTextField.frame.origin.x, -self.lastNameTextField.frame.size.height, self.lastNameTextField.frame.size.width, self.lastNameTextField.frame.size.height);
        self.nextButton.frame = CGRectMake(self.nextButton.frame.origin.x, -self.nextButton.frame.size.height, self.nextButton.frame.size.width, self.nextButton.frame.size.height);
        if (!advancing) {
            self.backButton.alpha = 0;
            [self.backButton setEnabled:NO];
        }
    } completion:^(BOOL finished) {
        self.firstNameTextField.frame = CGRectMake(self.firstNameTextField.frame.origin.x, self.view.frame.size.height, self.firstNameTextField.frame.size.width, self.firstNameTextField.frame.size.height);
        self.lastNameTextField.frame = CGRectMake(self.lastNameTextField.frame.origin.x, self.view.frame.size.height, self.lastNameTextField.frame.size.width, self.lastNameTextField.frame.size.height);
        self.nextButton.frame = CGRectMake(self.nextButton.frame.origin.x, self.view.frame.size.height, self.nextButton.frame.size.width, self.nextButton.frame.size.height);
    }];
}

- (void) createSignUpPage2 {
    self.viewName = SIGNUP_VIEW2;
    [UIView animateWithDuration:0.5 animations:^{
        self.usernameSignUpTextField.frame = CGRectMake(self.usernameSignUpTextField.frame.origin.x, 100, self.usernameSignUpTextField.frame.size.width, self.usernameSignUpTextField.frame.size.height);
        self.passwordSignUpTextField.frame = CGRectMake(self.passwordSignUpTextField.frame.origin.x, self.usernameSignUpTextField.frame.origin.y + self.usernameSignUpTextField.frame.size.height + 20, self.passwordSignUpTextField.frame.size.width, self.passwordSignUpTextField.frame.size.height);
        self.confirmPasswordSignUpTextField.frame = CGRectMake(self.confirmPasswordSignUpTextField.frame.origin.x, self.passwordSignUpTextField.frame.origin.y + self.passwordSignUpTextField.frame.size.height + 20, self.confirmPasswordSignUpTextField.frame.size.width, self.confirmPasswordSignUpTextField.frame.size.height);
        self.signUpButton.frame = CGRectMake(self.signUpButton.frame.origin.x, self.confirmPasswordSignUpTextField.frame.origin.y + self.confirmPasswordSignUpTextField.frame.size.height + 20, self.signUpButton.frame.size.width, self.signUpButton.frame.size.height);
    }];
}

- (void) dismissSignUpPage2:(BOOL)advancing {
    [UIView animateWithDuration:0.5 animations:^{
        self.usernameSignUpTextField.frame = CGRectMake(self.usernameSignUpTextField.frame.origin.x, -self.usernameSignUpTextField.frame.size.height, self.usernameSignUpTextField.frame.size.width, self.usernameSignUpTextField.frame.size.height);
        self.passwordSignUpTextField.frame = CGRectMake(self.passwordSignUpTextField.frame.origin.x, -self.passwordSignUpTextField.frame.size.height, self.passwordSignUpTextField.frame.size.width, self.passwordSignUpTextField.frame.size.height);
        self.confirmPasswordSignUpTextField.frame = CGRectMake(self.confirmPasswordSignUpTextField.frame.origin.x, -self.confirmPasswordSignUpTextField.frame.size.height, self.confirmPasswordSignUpTextField.frame.size.width, self.confirmPasswordSignUpTextField.frame.size.height);
        self.signUpButton.frame = CGRectMake(self.signUpButton.frame.origin.x, -self.signUpButton.frame.size.height, self.signUpButton.frame.size.width, self.signUpButton.frame.size.height);
        if (advancing) {
            [self.backButton setEnabled:NO];
            self.backButton.alpha = 0;
        }
    } completion:^(BOOL finished) {
        self.usernameSignUpTextField.frame = CGRectMake(self.usernameSignUpTextField.frame.origin.x, self.view.frame.size.height, self.usernameSignUpTextField.frame.size.width, self.usernameSignUpTextField.frame.size.height);
        self.passwordSignUpTextField.frame = CGRectMake(self.passwordSignUpTextField.frame.origin.x, self.view.frame.size.height, self.passwordSignUpTextField.frame.size.width, self.passwordSignUpTextField.frame.size.height);
        self.confirmPasswordSignUpTextField.frame = CGRectMake(self.confirmPasswordSignUpTextField.frame.origin.x, self.view.frame.size.height, self.confirmPasswordSignUpTextField.frame.size.width, self.confirmPasswordSignUpTextField.frame.size.height);
        self.signUpButton.frame = CGRectMake(self.signUpButton.frame.origin.x, self.view.frame.size.height, self.signUpButton.frame.size.width, self.signUpButton.frame.size.height);
    }];
}



- (void) backButtonPressed {
    if ([self.viewName isEqualToString:SIGNIN_VIEW]) {
        [self dismissSignInPage];
        [self createContinuePage];
    } else if ([self.viewName isEqualToString:SIGNUP_VIEW1]) {
        [self dismissSignUpPage1:NO];
        [self createContinuePage];
    } else if ([self.viewName isEqualToString:SIGNUP_VIEW2]) {
        [self dismissSignUpPage2:NO];
        [self createSignUpPage1];
    }
}

- (void) continueButtonPressed {
    self.inputtedUserEmail = self.emailTextField.text;
    
    [[FIRAuth auth] fetchSignInMethodsForEmail:_inputtedUserEmail completion:^(NSArray<NSString *> * _Nullable listOfMethods, NSError * _Nullable error) {
        
        if(listOfMethods){
            [self dismissContinuePage];
            [self createSignInPage];
        }
        else{
            [self dismissContinuePage];
            [self createSignUpPage1];
        }
    }];
}


- (void) logInButtonPressed {
    self.inputtedPassword = self.passwordTextField.text;
    [[FIRAuth auth] signInWithEmail:self.inputtedUserEmail
                           password:self.inputtedPassword
                         completion:^(FIRAuthDataResult * _Nullable authResult,
                                      NSError * _Nullable error) {
                             //if authresult is nill then check for error
                             //non nill authresult means we can login
                             if (authResult.user){
                                 [self dismissSignInPage];
                                 [self segueToApp];
                                 User *retrievedUser = [[DataHandling shared] getUser:authResult.user.uid];
                                 [self.delegate userWasCreated:retrievedUser];
                             }
                             else{
                                 switch([error code]){
                                     case 17009:
                                         [self presentAlert:@"Wrong password" withMessage:@"Make sure password is correct"];
                                         break;
                                     case 17034:
                                         [self presentAlert:@"Email not provided" withMessage:@"Please provide an email"];
                                         break;
                                 }
                             }
                         }];
}


- (void) nextButtonPressed {
    BOOL signupIsCorrect = YES; // TODO: Implement later with Firebase code
    if (signupIsCorrect) {
        self.registerFirstName = self.firstNameTextField.text;
        self.registerLastName = self.lastNameTextField.text;
        [self dismissSignUpPage1:YES];
        [self createSignUpPage2];
    }
}

- (void) signUpButtonPressed {
    BOOL signupIsCorrect = [self.passwordSignUpTextField.text isEqualToString:self.confirmPasswordSignUpTextField.text];
    if (signupIsCorrect) {
        __block NSString *userID;
        self.registerUsername = self.usernameTextField.text;
        self.registerPassword = self.passwordSignUpTextField.text;
        NSDictionary *userInfo = @{
                                   @"First Name": self.registerFirstName,
                                   @"Last Name": self.registerLastName,
                                   //use defaults for profile image url and other fixed fields
                                   @"ProfileImageURL": @"random",
                                   @"User Bio": @"Hi",
                                   @"Screen Name": self.registerUsername,
                                   @"BackgroundImageURL": @"testing",
                                   @"Email": self.inputtedUserEmail,
                                   @"Password": self.registerPassword
                                   };
        [[FIRAuth auth] createUserWithEmail:self.inputtedUserEmail
                                   password:self.registerPassword
                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                              NSError * _Nullable error) {
                                     if(authResult){
                                         userID = authResult.user.uid;
                                         User *newUser = [[User alloc] initWithDictionary:userInfo];
                                         NSLog(@"New firebase user was created %@", authResult.user);
                                         [[DataHandling shared] addUserToDatabase:newUser withUserID:userID];
                                         [self dismissSignUpPage2:YES];
                                         [self segueToApp];
                                     }
                                     else{
                                         switch([error code]){
                                                 
                                             case 1707:
                                                 [self presentAlert:@"Email already in use" withMessage:@"Pleae restart signup with another email"];
                                                 break;
                                             case 1708:
                                                 [self presentAlert:@"Invalid Email" withMessage:@"Make sure email was in right format"];
                                                 break;
                                             case 17026:
                                                 [self presentAlert:@"Password is too weak" withMessage:@"Please input a stronger password"];
                                                 break;
                                         }
                                     }
                                 }];
        NSLog(@"USER WILL BE CREATED NOW");
    }
    else{
        [self presentAlert:@"Passwords Don't Match" withMessage:@"Make sure your password fields match"];
        self.passwordSignUpTextField.text = @"";
        self.confirmPasswordSignUpTextField.text = @"";
    }
}


- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult,
                                                                     NSError * _Nullable error) {
            if (error) {
                NSLog(AUTHENTICATION_ERROR);
            }
            // User successfully signed in
            if (authResult == nil) {
                NSLog(@"WAS NOT ABLE TO SIGN USER IN");
                return;
            }
            NSLog(@"SUCCESSFULLY AUTHENTICATED USER");
        }];
    } else {
        NSLog(AUTHENTICATION_ERROR);
    }
}


- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSLog(@"FACEBOOK LOGOUT WAS PRESSED");
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(SIGN_OUT_FAILURE);
        return;
    }
    else
    {
        NSLog(@"FACEBOOK LOGOUT SUCCESSFUL");
    }
}

- (void)presentAlert:(NSString *)alertTitle withMessage:(NSString *)alertMessage
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         // handle response here.
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showLoginScreen {
    [self createContinuePage];
}

@end
