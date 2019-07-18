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


@interface UserViewController ()

@property (strong, nonatomic) FIRDatabaseReference *refUsers;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add the FB login button
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
    self.refUsers = [[[FIRDatabase database] reference] child:@"Users"];
    
    [FBSDKProfile loadCurrentProfileWithCompletion:
     ^(FBSDKProfile *profile, NSError *error) {
         if (profile) {
             NSLog(@"Hello, %@!", profile.firstName);
             [self addUser:profile];
         }
     }];
    
    
    
}



- (void)addUser:(FBSDKProfile *)userProfile
{
    NSString *key = [[self.refUsers childByAutoId] key];
    NSDictionary *userInfo = @{
                               @"id":key,
                               @"First Name": userProfile.firstName,
                               @"Last Name": userProfile.lastName
                               };
    [[self.refUsers child:key] setValue: userInfo];
    NSLog(@"Successfully saved info to database");
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
