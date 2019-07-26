//
//  ViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowLoginScreenDelegate
- (void)showLoginScreen;
@end

@interface MasterViewController : UIViewController

@property (nonatomic, weak) id<ShowLoginScreenDelegate> delegate;

@end

