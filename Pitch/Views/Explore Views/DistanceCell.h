//
//  DistanceCell.h
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOPDropDownMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface DistanceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *subview;
@property (weak, nonatomic) IBOutlet UISlider *slider;

- (void) resetDistance;

@end

NS_ASSUME_NONNULL_END
