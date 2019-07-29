//
//  NumberOfPeopleCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "NumberOfPeopleCell.h"

@implementation NumberOfPeopleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.toggleButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toggleButtonPressed:(id)sender {
    if ([self.toggleButton.titleLabel.text isEqualToString:@"Less than"]) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.toggleButton setTitle:@"Greater than" forState:UIControlStateNormal];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.toggleButton setTitle:@"Less than" forState:UIControlStateNormal];
        }];
    }
}

@end
