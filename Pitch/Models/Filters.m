//
//  Filters.m
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "Filters.h"

@interface Filters ()
@property BOOL filtersEnabled;
@property (strong, nonatomic) NSMutableArray *selectedVibesMArray;
@property NSInteger selectedDistance;
@property NSInteger selectedMinPeople;
@property NSInteger selectedMaxPeople;
@property NSInteger selectedAgeLimit;
@end

@implementation Filters
- (instancetype)init {
    self = [super init];
    if (self) {
        // TODO: Implement
        self.filtersEnabled = NO;
        self.selectedVibesMArray = [[NSMutableArray alloc] init];
        self.selectedDistance = 5;
        self.selectedMinPeople = 10;
        self.selectedMaxPeople = 100;
        self.selectedAgeLimit = 0;
    }
    return self;
}

+ (instancetype)sharedFilters {
    static Filters *sharedFilters = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFilters = [[self alloc] init];
    });
    return sharedFilters;
}

- (NSMutableArray *) getSelectedVibes {
//    if (self.filtersEnabled) {
        return self.selectedVibesMArray;
//    } else {
//        return nil;
//    }
}

- (void) setSelectedVibes:(NSMutableArray *)selectedVibesMArray {
    self.selectedVibesMArray = selectedVibesMArray;
}

- (NSInteger) getSelectedDistance {
//    if (self.filtersEnabled) {
        return self.selectedDistance;
//    } else {
//        return 0;
//    }
}

- (void) setDistance:(NSInteger)selectedDistance {
    self.selectedDistance = selectedDistance;
}

- (NSInteger) getSelectedMinPeople {
//    if (self.filtersEnabled) {
        return self.selectedMinPeople;
//    } else {
//        return 0;
//    }
}

- (void) setMinNumPeople:(NSInteger)minNumPeople {
    self.selectedMinPeople = minNumPeople;
}

- (NSInteger) getSelectedMaxPeople {
//    if (self.filtersEnabled) {
        return self.selectedMaxPeople;
//    } else {
//        return INFINITY;
//    }
}

- (void) setMaxNumPeople:(NSInteger)maxNumPeople {
    self.selectedMaxPeople = maxNumPeople;
}

- (NSInteger) getSelectedAgeRestriction {
//    if (self.filtersEnabled) {
        return self.selectedAgeLimit;
//    } else {
//        return 0;
//    }
}

- (void)setSelectedAgeRestriction:(NSInteger)selectedAgeLimit {
    self.selectedAgeLimit = selectedAgeLimit;
}

- (BOOL) getAreFiltersEnabled {
    return self.filtersEnabled;
}

- (void) setAreFiltersEnabled:(BOOL)enabled {
    self.filtersEnabled = enabled;
}

@end
