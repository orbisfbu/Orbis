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

@interface DistanceCell : UITableViewCell <DOPDropDownMenuDelegate, DOPDropDownMenuDataSource>
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) DOPDropDownMenu *menu;
//@property (weak, nonatomic) IBOutlet UIPickerView *distancePickerView;
@end

NS_ASSUME_NONNULL_END
