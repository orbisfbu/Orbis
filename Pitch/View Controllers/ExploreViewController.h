//
//  ExploreViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

NS_ASSUME_NONNULL_BEGIN

@interface ExploreViewController : UIViewController
- (void)dismissEventDetails: (UISwipeGestureRecognizer *)recognizer;
@end

NS_ASSUME_NONNULL_END
