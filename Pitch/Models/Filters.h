//
//  Filters.h
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Filters : NSObject
+ (instancetype) sharedFilters;
- (NSMutableArray *) getSelectedVibes;
- (void) setSelectedVibes:(NSMutableArray *)selectedVibesMArray;
- (NSInteger) getSelectedDistance;
- (void) setDistance:(NSInteger)selectedDistance;
- (NSInteger) getSelectedMinPeople;
- (void) setMinNumPeople:(NSInteger)minNumPeople;
- (NSInteger) getSelectedMaxPeople;
- (void) setMaxNumPeople:(NSInteger)maxNumPeople;
- (NSInteger) getSelectedAgeRestriction;
- (void)setSelectedAgeRestriction:(NSInteger)selectedAgeLimit;
- (BOOL) getAreFiltersEnabled;
- (void) setAreFiltersEnabled:(BOOL)enabled;
@end

NS_ASSUME_NONNULL_END
