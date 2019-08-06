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

@protocol DataHandlingDelegate
- (void)refreshEventsDelegateMethod:(NSArray *)events;
@end

@protocol InstantiateSharedUserDelegate
- (void)segueToAppUponLogin;
@end

@protocol EventInfoForAnnotationDelegate
- (void)eventDataForDetailedView:(NSDictionary *)eventData;
@end


@interface DataHandling : NSObject
+ (instancetype)shared;
- (void)getEventsFromDatabase;
- (void)addEventToDatabase:(Event *)definedEvent;
- (void)addUserToDatabase:(User *)thisUser withUserID:(NSString *)createdUserID;
- (void)loadUserInfoAndApp: (NSString *)userID;
- (void)registerUserToEvent: (Event *)eventName;
- (void)unregisterUser: (Event *)event;
@property (nonatomic, weak) id<DataHandlingDelegate> delegate;
@property (nonatomic, weak) id<InstantiateSharedUserDelegate> sharedUserDelegate;
@property (nonatomic, weak) id<EventInfoForAnnotationDelegate> eventAnnotationDelegate;

// Mario's methods
- (void) getEvent:(NSString *)eventID withCompletion:(void (^) (Event *event))completion;

@end

NS_ASSUME_NONNULL_END
