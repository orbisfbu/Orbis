//
//  Vibes.h
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Vibes : NSObject

- (NSArray *) getVibesArray;
+ (instancetype) sharedVibes;

@end

NS_ASSUME_NONNULL_END
