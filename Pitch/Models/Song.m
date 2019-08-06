//
//  Song.m
//  Pitch
//
//  Created by mariobaxter on 8/2/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "Song.h"

@implementation Song

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSLog(@"%@", dict);
        self.albumName = dict[@"Album Name"];
        NSLog(@"OK HERE");
        self.artistName = dict[@"Artist Name"];
        NSLog(@"OK HERE");
        self.title = dict[@"Title"];
        NSLog(@"OK HERE");
        self.numLikes = [dict[@"numLikes"] longValue];
        NSLog(@"OK HERE");
    }
    return self;
}

@end
