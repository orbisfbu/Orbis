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
        self.albumName = dict[@"Album Name"];
        self.artistName = dict[@"Artist Name"];
        self.title = dict[@"Title"];
        self.numLikes = [dict[@"numLikes"] longValue];
        self.userIDsThatHaveLikedSong = dict[@"userIDs"];
    }
    return self;
}

@end
