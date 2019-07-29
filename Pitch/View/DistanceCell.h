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
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *distanceToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *unitButton;

@end

NS_ASSUME_NONNULL_END
