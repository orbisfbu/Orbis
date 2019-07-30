//
//  NumberOfPeopleCell.h
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MARKRangeSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface NumberOfPeopleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *subview;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) MARKRangeSlider *rangeSlider;

- (void) resetNumberOfPeople;

@end

NS_ASSUME_NONNULL_END
