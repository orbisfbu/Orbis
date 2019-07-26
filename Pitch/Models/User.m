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
        self.userNameString = [firstNameFormatted stringByAppendingString: dictionary[@"Last Name"]];
        self.profileImageURLString = dictionary[@"ProfileImageURL"];
        self.userPassword = dictionary[@"Password"];
        self.userBioString = dictionary[@"User Bio"];
        self.screenNameString = dictionary[@"Screen Name"];
        self.profileBackgroundImageURLString = dictionary[@"BackgroundImageURL"];
        self.email = dictionary[@"Email"];
    }
    return self;
    
}


@end
