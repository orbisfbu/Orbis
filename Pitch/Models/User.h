//
//  User.h
//  Pitch
//
//  Created by sbernal0115 on 7/18/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@import UIKit;
@import Firebase;
@import FirebaseAuth;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, strong) NSString *userNameString;
@property (nonatomic, strong) NSString *screenNameString;
@property (nonatomic, strong) NSString *userBioString;
@property (nonatomic, strong) NSString *profileImageURLString;
@property (nonatomic, strong) NSString *profileBackgroundImageURLString;
@property (nonatomic, strong) NSString *email;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
