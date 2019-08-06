//
//  ApplyFiltersCell.m
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "ApplyFiltersCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ApplyFiltersCell ()
@property (strong, nonatomic) Filters *filters;
@end

@implementation ApplyFiltersCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.filters = [Filters sharedFilters];
    [self.applyFiltersButton setBackgroundColor:UIColorFromRGB(0x157f5f)];
    [self.applyFiltersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.applyFiltersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.applyFiltersButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    self.applyFiltersButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)applyfiltersButtonPressed:(id)sender {
    if ([self.applyFiltersButton.titleLabel.text isEqualToString:@"Apply Filters"]) {
        [self.applyFiltersButton setTitle:@"Reset Filters" forState:UIControlStateNormal];
        [self.delegate applyFiltersButtonWasPressed];
    } else {
        [self.applyFiltersButton setTitle:@"Apply Filters" forState:UIControlStateNormal];
        [self.delegate resetFiltersButtonWasPressed];
    }
}

@end
