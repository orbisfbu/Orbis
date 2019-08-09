//
//  ApplyFiltersCell.h
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filters.h"
#import "CustomFilterButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ApplyFiltersDelegate
- (void) applyFiltersButtonDelegate;
- (void) resetFiltersButtonDelegate;
@end


@interface ApplyFiltersCell : UITableViewCell
@property (weak, nonatomic) CustomFilterButton *applyFiltersButton;
- (void)applyFiltersButtonPressed:(BOOL)eventsWereFound;
@property (nonatomic, weak) id<ApplyFiltersDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
