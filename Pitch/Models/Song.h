//
//  Song.h
//  Pitch
//
//  Created by mariobaxter on 8/2/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Song : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *albumName;
@property long numLikes;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
