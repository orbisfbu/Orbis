//
//  DistanceCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DistanceCell.h"

@implementation DistanceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dataArray = @[@"Less than ", @"Greater than "];
    self.distanceToggleButton.layer.cornerRadius = 10;
    [self.distanceToggleButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)toggleButtonPressed:(id)sender {
    if ([self.distanceToggleButton.titleLabel.text isEqualToString:@"Less than"]) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.distanceToggleButton setTitle:@"Greater than" forState:UIControlStateNormal];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.distanceToggleButton setTitle:@"Less than" forState:UIControlStateNormal];
        }];
    }
}

//- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
//    return 2;
//}
//
//- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath {
//    NSLog(@"HERE BOIIIIIII");
//    return self.dataArray[indexPath.item];
//}
//
//- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
//    NSLog(@"HERE BOIIIIIII");
//    return self.dataArray[indexPath.row];
//}

@end
