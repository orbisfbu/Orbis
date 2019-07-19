//
//  UserViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "UserViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
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

@interface UserViewController () <FBSDKLoginButtonDelegate>

@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add the FB login button
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self; // added
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    loginButton.permissions = @[@"public_profile", @"email"];
    self.databaseUsersReference = [[[FIRDatabase database] reference] child:@"Users"];
}

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


- (void)addUserToDatabase:(FIRUser *)currentUser

{
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
    //eventually create a class full of getters for the User class
    //this APImanager class should implement the backend to retrieve user information from
    //the Firebase Database --> create similiar class for the Event objects as well
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[self.databaseUsersReference child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *retrievedURLString = snapshot.value[USER_PROFILE_IMAGE_URLSTRING];
        NSURL *profileImageNSURL = [NSURL URLWithString:retrievedURLString];
        [self.profilePicImageView setImageWithURL:profileImageNSURL];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(DATA_FETCH_ERROR);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


