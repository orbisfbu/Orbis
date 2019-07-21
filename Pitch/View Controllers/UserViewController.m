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

@import UIKit;
@import Firebase;
@import FirebaseAuth;

//Fields to be used when saving user to database
static NSString * const DATABASE_USER_NODE = @"Users";
static NSString * const USER_FIRSTNAME = @"First Name";
static NSString * const USER_LASTNAME = @"Last Name";
static NSString * const USER_EMAIL = @"Email";
static NSString * const USER_PROFILE_IMAGE_URLSTRING = @"ProfileImage";

//Required permissions for user info
static NSString * const PUBLIC_PROFILE_PERMISSION = @"public_profile";
static NSString * const EMAIL_PERSMISSION = @"email";

//Debugging/Error Messages
static NSString * const SUCCESSFUL_USER_SAVE = @"Successfully saved User info to database";
static NSString * const SIGN_OUT_FAILURE = @"Error occured while signing out";
static NSString * const AUTHENTICATION_ERROR = @"Error occured while authenticating user";
static NSString * const DATA_FETCH_ERROR = @"An error occured while retrieving User profile image";

@interface UserViewController () <FBSDKLoginButtonDelegate, UITextFieldDelegate>

@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;

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
@end


@implementation UserViewController



- (void)viewDidAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad {
    //user currentAccessToken to detect whether a Facebook user
    //is already logged-in; if so, automatically load the profile
    //and profile picture when userView is selected
    [super viewDidLoad];
    [self showFirstTimeUserPage];
    //hide the backbutton unless user proceeds with signup
    self.backButtonOutlet.hidden = YES;
    self.FBLoginButtonOutlet.delegate = self;
    self.FBLoginButtonOutlet.permissions = @[PUBLIC_PROFILE_PERMISSION, EMAIL_PERSMISSION];
    if ([FBSDKAccessToken currentAccessToken]) {
        [self setUserProfileImage];
        NSLog(@"User was already logged in");
    }
    else
    {
        NSLog(@"No user signed in; no profile image to load");
    }
    self.databaseUsersReference = [[[FIRDatabase database] reference] child:DATABASE_USER_NODE];
}


- (void)addUserToDatabase:(FIRUser *)currentUser{
    NSString *userID = [FIRAuth auth].currentUser.uid;
    //Display name is a string of the full name
    //Separating it below
    NSString *fullName = currentUser.displayName;
    NSArray *nameArray = [fullName componentsSeparatedByString:@" "];
    NSString *profileImageURLString = [currentUser.photoURL absoluteString];
    NSDictionary *userInfo = @{
                               USER_FIRSTNAME: [nameArray objectAtIndex:0],
                               USER_LASTNAME: [nameArray  objectAtIndex:1],
                               USER_PROFILE_IMAGE_URLSTRING : profileImageURLString,
                               USER_EMAIL: currentUser.email
                               };
    [[self.databaseUsersReference child:userID] setValue: userInfo];
    NSLog(SUCCESSFUL_USER_SAVE);
}

//will be called whenever Facebook login/authentication is successful
//OR the user has changed profile image in profileViewController
- (void)setUserProfileImage
{
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

//call this if the user hasn't signed up or logged-in
- (void)showFirstTimeUserPage
{
    self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (void)showTheBasicsPage1
{
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
    
    
    UITextField *lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 300, 40)];
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


- (void)showTheBasicsPage2
{
    
    
    
}


//this function will be called if the user had already signed in before
//this function will load the elements that are to be displayed in the profileView
//this function should end up calling the setUserProfileImage method defined earlier
- (void)showUserProfile:(BOOL *) isSignedIn
{
    
    
}


- (void)dismissFirstTimeUserPage
{
    self.continueButtonOutlet.hidden = YES;
    self.emailTextField.hidden = YES;
    self.welcomingMessageLabel.hidden = YES;
    self.FBLoginButtonOutlet.hidden = YES;
    self.orSeparatorLabel.hidden = YES;
    self.backButtonOutlet.hidden = NO;
}

- (void)dismissTheBasicsPage1
{
//    for (UIView *view in [self.view subviews]) {
//        if (view.restorationIdentifier isEqualToString:@"")
//    }
}


- (void)dismissTheBasicsPage2
{
    
    
    
}

- (void)dismissUserProfile
{
    
    
}


- (IBAction)continueButtonAction:(id)sender {
    if (self.emailTextField.text && self.emailTextField.text.length > 0)
    {
        //need to check if that email is already in the database
        [self dismissFirstTimeUserPage];
        [self showTheBasicsPage1];
    }
    else
    {
        [self presentAlert:@"Invalid Email" withMessage:@"Please provide a valid email"];
    }
}

//FacebookLoginButton methods
//if user successfully logins with Facebook
//they'll be added to the databse and their profile image will be set
- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
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

@end


