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
@import UIKit;
@import Firebase;
@import FirebaseAuth;

@interface UserViewController () <FBSDKLoginButtonDelegate>

@property (strong, nonatomic) FIRDatabaseReference *refUsers;

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
    self.refUsers = [[[FIRDatabase database] reference] child:@"Users"];
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
                                          // ...
                                          return;
                                      }
                                      // User successfully signed in. Get user data from the FIRUser object
                                      if (authResult == nil) { return; }
                                      FIRUser *user = authResult.user;
                                      NSString *email = user.email;
                                      NSLog(@"%@", email);
                                      NSString *userID = user.uid;
                                      NSLog(@"%@", userID);
                                      NSString *photoURL = user.photoURL;
                                      NSLog(@"%@", photoURL);
                                      NSString *userName = user.displayName;
                                      NSLog(@"%@", userName);
                                      
                                      // ...
                                  }];
    } else {
        NSLog(error.localizedDescription);
    }
}



- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
}

//
//- (void)addUser:(FIRUser *)currentUser
//{
//    NSString *key = [[self.refUsers childByAutoId] key];
//    NSDictionary *userInfo = @{
//                               @"id":key,
//                               @"First Name": userProfile.firstName,
//                               @"Last Name": userProfile.lastName
//                               };
//    [[self.refUsers child:key] setValue: userInfo];
//    NSLog(@"Successfully saved info to database");
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


