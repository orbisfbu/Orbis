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
        NSLog(@"89function got called");
        self.userNameString = dictionary[@"First Name"];
        //self.screenNameString = [NSString stringWithFormat:@"%@", dictionary[@""]];
        //self.userBioString = dictionary[@"user_bio"];
        self.profileImageURLString = dictionary[@"ProfileImage"];
        //self.profileBackgroundImageURLString = dictionary[@"background_image_url_https"];
    }
    return self;
}


@end
