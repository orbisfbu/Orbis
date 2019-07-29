//
//  DistanceCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DistanceCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation DistanceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.subview.layer.cornerRadius = 5;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.distanceLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.slider setMaximumValue:50];
    [self.slider setMinimumValue:1];
    [self.slider setValue:5];
    [self.slider setMinimumTrackTintColor:UIColorFromRGB(0x21ce99)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)sliderDidSlide:(id)sender {
    [self.distanceLabel setText:[NSString stringWithFormat:@"%i km", (int)self.slider.value]];
}

@end
