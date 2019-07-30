//
//  ApplyFiltersCell.m
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "ApplyFiltersCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ApplyFiltersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.applyFiltersButton setBackgroundColor:UIColorFromRGB(0x21ce99)];
    [self.applyFiltersButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    self.applyFiltersButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)applyfiltersButtonPressed:(id)sender {
    if ([self.applyFiltersButton.titleLabel.text isEqualToString:@"Apply Filters"]) {
        [self.applyFiltersButton setTitle:@"Reset Filters" forState:UIControlStateNormal];
    } else {
        [self.applyFiltersButton setTitle:@"Apply Filters" forState:UIControlStateNormal];
    }
}

@end
