//
//  MusicQueueViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicQueueViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *clickableMapViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *scrollViewSubview;
@property (weak, nonatomic) IBOutlet UIView *queueSectionTabOutlet;
@property (weak, nonatomic) IBOutlet UIView *swipeIndicatorOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *queueSectionTitleLabel;
@property (nonatomic) BOOL registrationStatusForEvent;
@end

NS_ASSUME_NONNULL_END
