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
#import "Song.h"

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
- (void)setUserProfileImage:(UIImageView *)profile_imageImageView;
- (void)addEventToDatabase:(Event *)definedEvent;
- (void)addUserToDatabase:(User *)thisUser withUserID:(NSString *)createdUserID;
- (void)loadUserInfoAndApp: (NSString *)userID;
- (void)getFilteredEventsFromDatabase: (NSDictionary*)filters userLocation:(CLLocation*)userLocation;
- (void)updateProfileImage:(UIImage*)imageToUpload withCompletion:(void (^) (NSString *createdProfileImageURLString))completion ;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, weak) id<GetEventsArrayDelegate> delegate;
@property (nonatomic, weak) id<GetFilteredEventsArrayDelegate> filteredEventsDelegate;
@property (nonatomic, weak) id<InstantiateSharedUserDelegate> sharedUserDelegate;
// Mario's methods
- (void) getEvent:(NSString *)eventID withCompletion:(void (^) (Event *event))completion;
- (void) user:(NSString *)userID didLikeSong:(Song *)song atIndex:(NSInteger)index atEvent:(NSString *)eventID;
- (void) user:(NSString *)userID didUnlikeSong:(Song *)song atIndex:(NSInteger)index atEvent:(NSString *)eventID;
- (void)registerUserToEvent: (Event *)eventName;
- (void)unregisterUser: (Event *)event;
@end

NS_ASSUME_NONNULL_END
