//
//  User.m
//  Pitch
//
//  Created by sbernal0115 on 7/18/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary { // returns a User
    self = [super init];
    if (self) {
        self.userNameString = dictionary[@"First Name"];
        self.profileImageURLString = dictionary[@"ProfileImage"];
    }
    return self;
}


@end
