//
//  DataHandling.h
//  Pitch
//
//  Created by sbernal0115 on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseDatabase/FirebaseDatabase.h"
#import "Event.h"
#import "User.h"
#import "UserInSession.h"

@import UIKit;
@import Firebase;
@import FirebaseAuth;
@import FirebaseCore;
@import FirebaseFirestore;

NS_ASSUME_NONNULL_BEGIN

@protocol GetEventsArrayDelegate
- (void)refreshEventsDelegateMethod:(NSArray *)events;
@end

@protocol InstantiateSharedUserDelegate
- (void)segueToAppUponLogin;
@end

@protocol EventInfoForAnnotationDelegate
- (void)eventDataForDetailedView:(NSDictionary *)eventData;
@end

@protocol GetFilteredEventsArrayDelegate
- (void)refreshFilteredEventsDelegateMethod:(NSArray *)filteredEvents;
@end

@interface DataHandling : NSObject
+ (instancetype)shared;
- (void)getEventsFromDatabase;
- (void)addEventToDatabase:(Event *)definedEvent;
- (void)addUserToDatabase:(User *)thisUser withUserID:(NSString *)createdUserID;
- (void)loadUserInfoAndApp: (NSString *)userID;
- (void)userRegisteredForEvent: (NSString *)eventName;
- (void)unregisterUser: (NSString *)eventName;
- (void)getInfoForEventAnnotionWithTitle: (NSString *)title withCoordinates:
(CLLocationCoordinate2D)coordinates;
- (void)getFilteredEventsFromDatabase: (NSDictionary*)filters;
@property (nonatomic, weak) id<GetEventsArrayDelegate> delegate;
@property (nonatomic, weak) id<InstantiateSharedUserDelegate> sharedUserDelegate;
@property (nonatomic, weak) id<EventInfoForAnnotationDelegate> eventAnnotationDelegate;
@property (nonatomic, weak) id<GetFilteredEventsArrayDelegate> filteredEventsDelegate;
@end

NS_ASSUME_NONNULL_END
