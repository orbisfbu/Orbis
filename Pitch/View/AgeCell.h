//
//  AgeCell.h
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCircularProgressBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *leftCircularView;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *rightCircularView;
@property (weak, nonatomic) IBOutlet UIView *subview;

@end

NS_ASSUME_NONNULL_END
