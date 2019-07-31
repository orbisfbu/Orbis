//
//  EventDetailsViewController.m
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventDetailsViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    self.scrollViewOutlet.clipsToBounds = YES;
    self.eventNameViewOutlet.layer.cornerRadius = 30;
    self.swipeIndicatorOutlet.layer.cornerRadius = self.swipeIndicatorOutlet.frame.size.height/2;
    self.eventNameViewOutlet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    [self.scrollViewOutlet setShowsVerticalScrollIndicator:NO];
    [self.swipeIndicatorOutlet setBackgroundColor:[UIColor lightGrayColor]];
    [self.eventNameViewOutlet setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    self.roundedCornersViewOutlet.backgroundColor = UIColorFromRGB(0x21ce99);
self.scrollViewOutlet.contentInsetAdjustmentBehavior = 2;
    [super viewDidLoad];
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEventDetails:)];
    [self.clickableMapViewOutlet addGestureRecognizer:tapMap];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEventDetails:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.eventNameViewOutlet addGestureRecognizer: downGestureRecognizer];
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

- (void)dismissEventDetails:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
