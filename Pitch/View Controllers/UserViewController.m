//
//  UserViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "UserViewController.h"
#import "FirebaseDatabase/FirebaseDatabase.h"
#import "AppDelegate.h"
#import "UserViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FBSDKLoginManagerLoginResult.h"
#import <FBSDKAccessToken.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@import UIKit;
@import Firebase;
@import FirebaseAuth;

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
static NSString * const PROFILE_VIEW = @"PROFILE_VIEW";

// Constant max and min heights of profile background image view
static double const BACKGORUND_IMAGE_MIN_HEIGHT = 50.0;
static double const BACKGORUND_IMAGE_MAX_HEIGHT = 250.0;

@interface UserViewController () <FBSDKLoginButtonDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;

@property (strong, nonatomic) FBSDKLoginButton *FBLoginButton;

//this flag will be used to trigger initial loading
//if YES, then profile will be loaded
//if NO, then sign-in/signup views will be displayed
@property (nonatomic) BOOL *userIsSignedIn;

//inputted properties to be used and checked during
//the welcoming process; will have to check whether or not
//initially inputted email and password correspond to existing account
@property (weak, nonatomic) NSString *inputtedUserEmail;
@property (weak, nonatomic) NSString *inputtedPassword;
//these registering properties are to be set if inputted email doesn't
//correspond to an account
@property (weak, nonatomic) NSString *registerFirstName;
@property (weak, nonatomic) NSString *registerLastName;
@property (weak, nonatomic) NSString *registerUsername;
//for the password confirm field later on, just make sure that
//the text of that cofirm password field is the same registerPassword
@property (weak, nonatomic) NSString *registerPassword;

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

// For user profile screen
@property (strong, nonatomic) UIImageView *userBackgroundImageView;
@property (strong, nonatomic) UIImageView *userProfileImageView;
@property (strong, nonatomic) UITableView *userProfileTableView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIButton *editProfileButton;

@end


@implementation UserViewController

- (void)viewDidLoad {
    //user currentAccessToken to detect whether a Facebook user
    //is already logged-in; if so, automatically load the profile
    //and profile picture when userView is selected
    [super viewDidLoad];
    [self.backButton setEnabled:NO];
    self.backButton.alpha = 0;
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.FBLoginButton.delegate = self;
    self.FBLoginButton.permissions = @[PUBLIC_PROFILE_PERMISSION, EMAIL_PERSMISSION];
    
    // Add touch gestures to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self createPageObjects];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"User was already logged in... Creating user profile");
        [self createUserProfile];
    } else {
        NSLog(@"No user signed in... Creating sign in/up page");
        [self createContinuePage];
    }
    self.databaseUsersReference = [[[FIRDatabase database] reference] child:DATABASE_USER_NODE];
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
    [self.confirmPasswordSignUpTextField setPlaceholder:@"Conform Password"];
    [self.confirmPasswordSignUpTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.confirmPasswordSignUpTextField];
    
    // Add signup button
    self.signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width - 60, 30)];
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpButton setBackgroundColor:[UIColor blackColor]];
    self.signUpButton.layer.cornerRadius = 5;
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signUpButton];
    
    // Add user background photo
    self.userBackgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200)];
    [self.userBackgroundImageView setImage:[UIImage imageNamed:@"default_background"]];
    [self.userBackgroundImageView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.userBackgroundImageView];
    
    // Add profile scroll view
    self.userProfileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.userBackgroundImageView.frame.size.height) style:UITableViewStylePlain];
    self.userProfileTableView.delegate = self;
    self.userProfileTableView.dataSource = self;
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.view addSubview:self.userProfileTableView];
    
    // Add user profile photo
    self.userProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width/3, self.view.frame.size.width/3)];
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width/2;
    [self.userProfileImageView setImage:[UIImage imageNamed:@"default_profile"]];
    [self.userProfileImageView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.userProfileImageView];
    
    // Add username label
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height, 100, 20)];
    [self.usernameLabel setFont:[UIFont fontWithName:@"roboto" size:20]];
    [self.usernameLabel setClipsToBounds:YES];
    self.usernameLabel.layer.cornerRadius = 5;
    [self.usernameLabel setText:@" @user_name "];
    [self.usernameLabel sizeToFit];
    [self.usernameLabel setCenter:CGPointMake(self.view.center.x, self.usernameLabel.center.y)];
    [self.usernameLabel setBackgroundColor:UIColorFromRGB(0x157f5f)];
    [self.view addSubview:self.usernameLabel];
    
    // Add edit profile button
    self.editProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 30, self.view.frame.size.height, 30, 30)];
    [self.editProfileButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [self.editProfileButton setBackgroundColor:UIColorFromRGB(0x157f5f)];
    self.editProfileButton.layer.cornerRadius = 5;
    [self.editProfileButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.editProfileButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editProfileButton];
}

- (void) createUserProfile {
    self.viewName = PROFILE_VIEW;
    
    // Add table view constraints needed for animation
//    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.userProfileTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userBackgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.userProfileTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
//    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.userProfileTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
//    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.userProfileTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//    [self.view addConstraints:@[top, left, right, bottom]];
    
//    [self.userProfileTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.userBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//    [[self.userBackgroundImageView.heightAnchor constraintLessThanOrEqualToConstant:200] setActive:YES];
//    [[self.userBackgroundImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    //[self.userBackgroundImageView addConstraint: [NSLayoutConstraint constraintWithItem:self.userBackgroundImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.userBackgroundImageView attribute:NSLayoutAttributeWidth multiplier:self.userBackgroundImageView.frame.size.height/self.userBackgroundImageView.frame.size.width constant:0]];
//    [[self.userBackgroundImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
//    [[self.userBackgroundImageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
//    [[self.userBackgroundImageView.bottomAnchor constraintEqualToAnchor:self.userProfileTableView.topAnchor] setActive:YES];
//
//    [[self.userProfileTableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
//    [[self.userProfileTableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
//    [[self.userProfileTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.userBackgroundImageView.frame = CGRectMake(self.userBackgroundImageView.frame.origin.x, 0, self.userBackgroundImageView.frame.size.width, self.userBackgroundImageView.frame.size.height);
        self.userProfileImageView.frame = CGRectMake(self.userProfileImageView.frame.origin.x, self.userBackgroundImageView.frame.size.height/3, self.userProfileImageView.frame.size.width, self.userProfileImageView.frame.size.height);
        self.userProfileTableView.frame = CGRectMake(self.userProfileTableView.frame.origin.x, self.userBackgroundImageView.frame.size.height, self.userProfileTableView.frame.size.width, self.userProfileTableView.frame.size.height);
        self.usernameLabel.frame = CGRectMake(self.usernameLabel.frame.origin.x, 15, self.usernameLabel.frame.size.width, self.usernameLabel.frame.size.height);
        self.editProfileButton.frame = CGRectMake(self.editProfileButton.frame.origin.x, 15, self.editProfileButton.frame.size.width, self.editProfileButton.frame.size.height);
    }];
}

- (void) dismissUserProfile {
    // Resize everything to original size, not the size it is modified to after scrolling
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
    BOOL emailExists = YES; // TODO: Implement later with Firebase code
    [self dismissContinuePage];
    if (emailExists) {
        [self createSignInPage];
    } else {
        [self createSignUpPage1];
    }
}

- (void) logInButtonPressed {
    BOOL loginIsCorrect = YES; // TODO: Implement later with Firebase code
    if (loginIsCorrect) {
        [self dismissSignInPage];
        [self createUserProfile];
    }
}

- (void) nextButtonPressed {
    BOOL signupIsCorrect = YES; // TODO: Implement later with Firebase code
    if (signupIsCorrect) {
        [self dismissSignUpPage1:YES];
        [self createSignUpPage2];
    }
}

- (void) signUpButtonPressed {
    BOOL signupIsCorrect = YES; // TODO: Implement later with Firebase code
    if (signupIsCorrect) {
        [self dismissSignUpPage2:YES];
        [self createUserProfile];
    }
}

- (void) editButtonPressed {
    
}


- (void)addUserToDatabase:(FIRUser *)currentUser{
    NSString *userID = [FIRAuth auth].currentUser.uid;
    //Display name is a string of the full name
    //Separating it below
    NSString *fullName = currentUser.displayName;
    NSArray *nameArray = [fullName componentsSeparatedByString:@" "];
    NSString *profileImageURLString = [currentUser.photoURL absoluteString];
    NSDictionary *userInfo = @{ USER_FIRSTNAME: [nameArray objectAtIndex:0], USER_LASTNAME: [nameArray  objectAtIndex:1], USER_PROFILE_IMAGE_URLSTRING : profileImageURLString, USER_EMAIL: currentUser.email};
    [[self.databaseUsersReference child:userID] setValue: userInfo];
    NSLog(SUCCESSFUL_USER_SAVE);
}

//will be called whenever Facebook login/authentication is successful
//OR the user has changed profile image in profileViewController
- (void)setUserProfileImage {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[self.databaseUsersReference child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *retrievedURLString = snapshot.value[USER_PROFILE_IMAGE_URLSTRING];
        NSURL *profileImageNSURL = [NSURL URLWithString:retrievedURLString];
        //self.profilePicImageView.image = nil;
        //[self.profilePicImageView setImageWithURL:profileImageNSURL];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(DATA_FETCH_ERROR);
    }];
}

////call this if the user hasn't signed up or logged-in
//- (void)showFirstTimeUserPage
//{
//    self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//}


- (void)showTheBasicsPage1 {
    UITextField *firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 300, 40)];
    firstNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    firstNameTextField.font = [UIFont systemFontOfSize:15];
    firstNameTextField.placeholder = @"First Name";
    firstNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    firstNameTextField.keyboardType = UIKeyboardTypeDefault;
    firstNameTextField.returnKeyType = UIReturnKeyDone;
    firstNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    firstNameTextField.alpha = .5;
    //textField.center = self.view.center;
    firstNameTextField.delegate = self;
    [self.view addSubview:firstNameTextField];
    //[textField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    firstNameTextField.translatesAutoresizingMaskIntoConstraints = YES;
    [firstNameTextField.widthAnchor constraintEqualToConstant:50.0].active = YES;
    [firstNameTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40.0].active = YES;
    [firstNameTextField.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50.0].active = YES;
    
    
    UITextField *lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, firstNameTextField.frame.origin.y + firstNameTextField.frame.size.height +10, 300, 40)];
    lastNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    lastNameTextField.font = [UIFont systemFontOfSize:15];
    lastNameTextField.placeholder = @"Last Name";
    lastNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    lastNameTextField.keyboardType = UIKeyboardTypeDefault;
    lastNameTextField.returnKeyType = UIReturnKeyDone;
    lastNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    lastNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    lastNameTextField.delegate = self;
    [self.view addSubview:lastNameTextField];
    
}
//FacebookLoginButton methods
//if user successfully logins with Facebook
//they'll be added to the databse and their profile image will be set
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
                                      if (authResult == nil) { return; }
                                      FIRUser *user = authResult.user;
                                      [self addUserToDatabase:user];
                                      [self setUserProfileImage];
                                  }];
    } else {
        NSLog(AUTHENTICATION_ERROR);
    }
}


- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(SIGN_OUT_FAILURE);
        return;
    }
}


- (IBAction)backButtonAction:(id)sender {
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"VibesCell"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int delta = scrollView.contentOffset.y;
    
    if (self.userBackgroundImageView.frame.size.height - delta < BACKGORUND_IMAGE_MIN_HEIGHT) {
        self.userBackgroundImageView.frame = CGRectMake(self.userBackgroundImageView.frame.origin.x, self.userBackgroundImageView.frame.origin.y, self.userBackgroundImageView.frame.size.width, BACKGORUND_IMAGE_MIN_HEIGHT);
        self.userProfileTableView.frame = CGRectMake(self.userProfileTableView.frame.origin.x, BACKGORUND_IMAGE_MIN_HEIGHT, self.userProfileTableView.frame.size.width, self.view.frame.size.height - BACKGORUND_IMAGE_MIN_HEIGHT);
    } else if (self.userBackgroundImageView.frame.size.height - delta > BACKGORUND_IMAGE_MAX_HEIGHT) {
        self.userBackgroundImageView.frame = CGRectMake(self.userBackgroundImageView.frame.origin.x, self.userBackgroundImageView.frame.origin.y, self.userBackgroundImageView.frame.size.width, BACKGORUND_IMAGE_MAX_HEIGHT);
        self.userProfileTableView.frame = CGRectMake(self.userProfileTableView.frame.origin.x, BACKGORUND_IMAGE_MAX_HEIGHT, self.userProfileTableView.frame.size.width, self.view.frame.size.height - BACKGORUND_IMAGE_MAX_HEIGHT);
    } else {
        NSLog(@"%i", delta);
        // Reframe the background image
        self.userBackgroundImageView.frame = CGRectMake(0, 0, self.userBackgroundImageView.frame.size.width, self.userBackgroundImageView.frame.size.height-delta);
        self.userProfileTableView.frame = CGRectMake(0, self.userBackgroundImageView.frame.size.height-delta, self.userBackgroundImageView.frame.size.width, self.view.frame.size.height - self.userBackgroundImageView.frame.size.height);
        // Reframe the profile image
        self.userProfileImageView.frame = CGRectMake(self.userProfileImageView.frame.origin.x, self.userProfileImageView.frame.origin.y - 0.45*delta, self.userProfileImageView.frame.size.width - 0.45*delta, self.userProfileImageView.frame.size.height - 0.45*delta);
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width/2;
        [self.userProfileTableView setContentOffset: CGPointMake(self.userProfileTableView.contentOffset.x, 0)];
    }
    float heightOfBackgroundImage = self.userBackgroundImageView.frame.size.height;
    if (heightOfBackgroundImage > BACKGORUND_IMAGE_MIN_HEIGHT && heightOfBackgroundImage < 200) {
        [self.userBackgroundImageView setAlpha:(heightOfBackgroundImage-BACKGORUND_IMAGE_MIN_HEIGHT + 20)/100];
    }
}

@end


