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
- (void)updateEvents:(NSArray *)events;
@end

@interface DataHandling : NSObject
+ (instancetype)shared;
- (void)getEventsArray;
- (void)addEventToDatabase:(Event *)definedEvent;
- (void)addUserToDatabase:(User *)thisUser withUserID:(NSString *)createdUserID;
- (void)loadUserInfoFromDatabase: (NSString *)userID;
@property (nonatomic, weak) id<DataHandlingDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
