//
//  UserViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
- (IBAction)continueButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *orSeparatorLabel;

// + (FBSDKAccessToken *) currentAccessToken;

@end

NS_ASSUME_NONNULL_END
