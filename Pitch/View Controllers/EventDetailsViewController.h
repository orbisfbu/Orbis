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
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIView *roundedCornersViewOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
@property (strong, nonatomic) IBOutlet UIView *eventNameViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *swipeIndicatorOutlet;
@property (strong, nonatomic) UILabel *eventCreatorLabel;
@property (strong, nonatomic) UILabel *eventDescriptionLabel;
@property (strong, nonatomic) UILabel *ageRestrictionLabel;
@property (strong, nonatomic) UILabel *distanceFromUserLabel;
@property (strong, nonatomic) UILabel *attendanceCountLabel;
@property (strong, nonatomic) UILabel *vibesLabel;
@property (strong, nonatomic) UILabel *pollSectionLabel;
@property (strong, nonatomic) UILabel *extraLabel;
@property (strong, nonatomic) UICollectionView *vibesCollectionView;
@property (strong, nonatomic) UIButton *registerButton;



//calculate this distance using difference in coordinates or something
//this distance should be set in explore view controller with the user's
//current location on the map
@property (nonatomic) int distanceFromUserInt;
@property (nonatomic) int eventAgeRestrictionInt;
@property (nonatomic) int eventAttendancCountInt;
@property (strong, nonatomic) UIImage *eventImage;
@property (strong, nonatomic) NSString *eventNameString;
@property (strong, nonatomic) NSString *eventCreatorString;
@property (strong, nonatomic) NSString *eventDescriptionString;
@property (strong, nonatomic) NSString *eventImageURLString;
@property (strong, nonatomic) NSArray *vibesArray;
@property (strong, nonatomic) NSDictionary *pollsDictionary;


@end

NS_ASSUME_NONNULL_END
