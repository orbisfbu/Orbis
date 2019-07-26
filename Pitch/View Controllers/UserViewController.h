//
//  UserViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DismissViewControllerDelegate
- (void) dismissViewController;
@end

@interface UserViewController : UIViewController
@property (nonatomic, weak) id<DismissViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
