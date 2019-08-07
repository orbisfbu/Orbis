//
//  User.m
//  Pitch
//
//  Created by sbernal0115 on 7/18/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "User.h"

static NSString * const USER_FIRSTNAME_KEY = @"First Name";
static NSString * const USER_LASTNAME_KEY = @"Last Name";
static NSString * const USER_EMAIL_KEY = @"Email";
static NSString * const USER_PROFILE_IMAGE_KEY = @"ProfileImageURL";
static NSString * const USERNAME_KEY = @"Username";
static NSString * const USER_BACKGROUND_KEY = @"BackgroundImageURL";
static NSString * const USER_BIO_KEY = @"Bio";
static NSString * const USER_ID_KEY = @"ID";

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary { // returns a User
    self = [super init];
    if (self) {
        NSString *firstNameFormatted = [NSString stringWithFormat:@"%@ ", dictionary[USER_FIRSTNAME_KEY]];
        self.nameString = [firstNameFormatted stringByAppendingString: dictionary[USER_LASTNAME_KEY]];
        self.profileImageURLString = dictionary[USER_PROFILE_IMAGE_KEY];
        self.userBioString = dictionary[USER_BIO_KEY];
        self.usernameString = dictionary[USERNAME_KEY];
        self.profileBackgroundImageURLString = dictionary[USER_BACKGROUND_KEY];
        self.email = dictionary[USER_EMAIL_KEY];
        self.ID = dictionary[USER_ID_KEY];
    }
    return self;
    
}


@end
