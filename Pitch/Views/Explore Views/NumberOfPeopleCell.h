//
//  NumberOfPeopleCell.h
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberOfPeopleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

NS_ASSUME_NONNULL_END
