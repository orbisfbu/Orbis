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
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *eventCreator;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *startDateString;
@property (nonatomic, strong) NSMutableArray *eventPollsArray;
@property (nonatomic) NSString *eventHasMusic;
@property (nonatomic, strong) NSString *eventImageURLString;
@property (nonatomic) NSString *eventDescription;
@property (nonatomic, strong) NSString *eventLocationString;
@property (nonatomic, strong) NSMutableArray *eventVibesArray;
@property (nonatomic) CLLocationCoordinate2D eventCoordinates;
@property (nonatomic, strong) NSMutableArray <NSString *> *registeredUsersArray;
@property (nonatomic) int eventAttendanceCount;
@property (nonatomic) int eventAgeRestriction;
@property (strong, nonatomic) NSMutableArray <Song *> *musicQueue;
@property (strong, nonatomic) NSMutableArray <UIImage *> *mediaArray;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
