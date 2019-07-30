//
//  AgeCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "AgeCell.h"
#import "Filters.h"

@interface AgeCell ()
@property (strong, nonatomic) Filters *filter;
@end

@implementation AgeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.filter = [Filters sharedFilters];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    self.subview.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)eighteenPlusButtonPressed:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        if (self.leftCircularView.value == 100) {
            self.leftCircularView.value = 0;
        } else {
            self.leftCircularView.value = 100;
            self.rightCircularView.value = 0;
            [self.filter setSelectedAgeRestriction:18];
        }
    }];
}

- (IBAction)twentyOnePlusButtonPressed:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        if (self.rightCircularView.value == 100) {
            self.rightCircularView.value = 0;
        } else {
            self.rightCircularView.value = 100;
            self.leftCircularView.value = 0;
            [self.filter setSelectedAgeRestriction:21];
        }
        
    }];
}

- (void)resetAgeRestrictions {
    [UIView animateWithDuration:1 animations:^{
        self.rightCircularView.value = 0;
        self.leftCircularView.value = 0;
    }];
    [self.filter setSelectedAgeRestriction:0];
}

@end
