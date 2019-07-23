//
//  Event.h
//  Pitch
//
//  Created by sbernal0115 on 7/18/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *eventOwnerUser;
@property (nonatomic, strong) NSString *eventNameString;
@property (nonatomic, strong) NSString *gatheringTypeString;
@property (nonatomic) BOOL musicAllowedBOOL;
@property (nonatomic) int peopleAttendingCount;
@property (nonatomic, strong) NSString *eventImageURLString;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) CLLocationDegrees latitudeDegrees;
@property (nonatomic, readwrite) CLLocationDegrees longitudeDegrees;

//+ (NSMutableArray *)eventVibesWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
