//
//  LogInViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/24/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "User.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginViewControllerDelegate
//check to see if the user was already in the database
//do this by using firebase and checking is snapshot with object id is null
//if it is, then pass the snapshot to self (self.delegate) after hasving instantiated
//that user with initWithDictionary --> snapshot.value
- (void)userWasCreated:(User*)createdUser;
@end

@interface LogInViewController : UIViewController
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
