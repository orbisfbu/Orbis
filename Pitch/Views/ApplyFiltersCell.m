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
    [self.applyFiltersButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.applyFiltersButton.layer.cornerRadius = 5;
}

- (void) buttonTouchUpInside:(id)sender {
    CustomFilterButton *buttonClicked = (CustomFilterButton *)sender;
    [self applyFiltersButtonPressed:buttonClicked.resultsWereFound];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)applyFiltersButtonPressed:(BOOL)eventsWereFound {
    if ([self.applyFiltersButton.titleLabel.text isEqualToString:@"Apply Filters"]) {
        [self.applyFiltersButton setTitle:@"Reset Filters" forState:UIControlStateNormal];
        [self.delegate applyFiltersButtonDelegate];
    } else {
        [self.applyFiltersButton setTitle:@"Apply Filters" forState:UIControlStateNormal];
        if (eventsWereFound){
            [self.delegate resetFiltersButtonDelegate];
        }
    }
}

@end
