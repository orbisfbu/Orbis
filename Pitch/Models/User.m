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
        NSString *firstNameFormatted = [NSString stringWithFormat:@"%@ ", dictionary[@"First Name"]];
        self.nameString = [firstNameFormatted stringByAppendingString: dictionary[@"Last Name"]];
        self.profileImageURLString = dictionary[@"ProfileImageURL"];
        self.userBioString = dictionary[@"User Bio"];
        self.usernameString = dictionary[@"Username"];
        self.profileBackgroundImageURLString = dictionary[@"BackgroundImageURL"];
        self.email = dictionary[@"Email"];
    }
    return self;
    
}


@end
