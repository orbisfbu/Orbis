//
//  EventDetailsViewController.h
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *clickableMapViewOutlet;
@property (retain, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventCreatorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageRestrictionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendanceCountLabel;
@property (weak, nonatomic) IBOutlet UIView *roundedCornersViewOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *eventNameViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *swipeIndicatorOutlet;


//calculate this distance using difference in coordinates or something
//this distance should be set in explore view controller with the user's
//current location on the map
@property (nonatomic) int distanceFromUser;
@property (strong, nonatomic) UIImage *eventImage;
@property (strong, nonatomic) NSString *eventNameString;
@property (strong, nonatomic) NSString *eventCreatorString;
@property (strong, nonatomic) NSString *eventDescriptionString;
@property (strong, nonatomic) NSString *eventImageURLString;
@property (strong, nonatomic) NSString *eventAgeRestrictionString;
@property (strong, nonatomic) NSString *eventAttendancCountString;


@end

NS_ASSUME_NONNULL_END
