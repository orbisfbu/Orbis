//
//  UserViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserViewController : UIViewController
- (IBAction)continueButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *orSeparatorLabel;
@property (readonly, nonatomic) BOOL isCancelled;
@property (weak, nonatomic) IBOutlet UIButton *continueButtonOutlet;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *FBLoginButtonOutlet;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *welcomingMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButtonOutlet;
- (IBAction)backButtonAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
