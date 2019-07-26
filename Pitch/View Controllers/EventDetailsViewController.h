//
//  EventDetailsViewController.h
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventCreatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventDescription;

@end

NS_ASSUME_NONNULL_END
