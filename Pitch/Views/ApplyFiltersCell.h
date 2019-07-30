//
//  ApplyFiltersCell.h
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filters.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ApplyFiltersDelegate
- (void) applyFiltersButtonWasPressed;
- (void) resetFiltersButtonWasPressed;
@end


@interface ApplyFiltersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *applyFiltersButton;
@property (nonatomic, weak) id<ApplyFiltersDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
