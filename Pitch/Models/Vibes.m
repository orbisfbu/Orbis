//
//  Vibes.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "Vibes.h"

@interface Vibes ()

@property (strong, nonatomic) NSArray *vibesArray;

@end

@implementation Vibes

- (instancetype)init {
    self = [super init];
    if (self) {
        self.vibesArray = @[@"Sports", @"Chill", @"Electronic", @"Jazz", @"Drinking", @"Party", @"Other"];
    }
    return self;
}

+ (instancetype)sharedVibes {
    static Vibes *sharedVibes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVibes = [[self alloc] init];
    });
    return sharedVibes;
}

- (NSArray *) getVibesArray {
    return self.vibesArray;
}

@end
