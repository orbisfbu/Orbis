//
//  EventDetailsViewController.m
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    self.roundedCornersView.layer.cornerRadius = 30;
    self.roundedCornersView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    [super viewDidLoad];
//    self.eventNameLabel.text = self.eventNameString;
//    NSURL *imageNSURL = [NSURL URLWithString:self.eventImageURLString];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageNSURL];
//    UIImage *eventImage = [UIImage imageWithData:imageData];
//    [self.eventImageView setImage:eventImage];
//    self.eventCreatorLabel.text = self.eventCreatorString;
//    self.eventDescriptionLabel.text = self.eventDescriptionString;
//    self.distanceFromUserLabel.text = [NSString stringWithFormat:@"%d", self.distanceFromUser];
//    self.ageRestrictionLabel.text = self.eventAgeRestrictionString;
//    self.attendanceCountLabel.text = self.eventAttendancCountString;
}


@end
