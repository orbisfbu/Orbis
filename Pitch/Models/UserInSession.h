//
//  UserInSession.h
//  Pitch
//
//  Created by sbernal0115 on 7/27/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInSession : NSObject
@property (strong, nonatomic) User *sharedUser;
@property (strong, nonatomic) NSMutableArray <Event *> *eventsCreatedMArray;
@property (strong, nonatomic) NSMutableArray <Event *> *eventsAttendedMArray;
+ (instancetype)shared;
- (void)setCurrentUser: (NSDictionary *)userInfo withUserID:(NSString *)userID;
@end

NS_ASSUME_NONNULL_END
