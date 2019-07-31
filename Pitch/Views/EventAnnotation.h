//
//  EventAnnotation.h
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventAnnotation : MKPinAnnotationView

@property (nonatomic, strong) NSString *eventImageURLString;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *eventCreator;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic) int *eventAgeRestriction;
@property (nonatomic) int *eventAttendanceCount;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *title;

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
