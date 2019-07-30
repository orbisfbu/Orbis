//
//  Event.h
//  Pitch
//
//  Created by sbernal0115 on 7/18/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSObject

// Add max and min number of people
@property int *minNumPeople;
@property int *maxNumPeople;

// Add array of Vibes

@property (nonatomic, strong) NSString *eventCreator;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSArray *eventVibesArray;
@property (nonatomic, strong) NSArray *eventPollsArray;
@property (nonatomic) NSString *eventHasMusic;
@property (nonatomic) NSInteger eventAttendanceCount;
@property (nonatomic, strong) NSString *eventImageURLString;
@property (nonatomic) NSString *eventDescription;
@property (nonatomic) NSInteger eventAgeRestriction;
@property (nonatomic, strong) NSString *eventLocationString;
//going to use google maps api and then createEvent method to correctly
//save the event coordinates
@property (nonatomic) CLLocationCoordinate2D eventCoordinates;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end

NS_ASSUME_NONNULL_END
