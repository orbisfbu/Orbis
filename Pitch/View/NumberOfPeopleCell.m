//
//  NumberOfPeopleCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "NumberOfPeopleCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation NumberOfPeopleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.subview.layer.cornerRadius = 5;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.numberLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    self.rangeSlider = [[MARKRangeSlider alloc] initWithFrame:CGRectMake(5, 5, self.subview.frame.size.width - 10, self.subview.frame.size.height - 10)];
    [self.rangeSlider addTarget:self action:@selector(rangeSliderValueDidChange:)
               forControlEvents:UIControlEventValueChanged];
    [self.rangeSlider setMinValue:1 maxValue:501];
    [self.rangeSlider setLeftValue:10 rightValue:150];
    
    NSArray *arrayOfImages = self.rangeSlider.subviews;
    UIImageView *imageView = arrayOfImages[1];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageView setTintColor: UIColorFromRGB(0x21ce99)];
    
    [self.subview addSubview:self.rangeSlider];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)rangeSliderValueDidChange:(MARKRangeSlider *)slider {
    if (slider.rightValue == slider.maximumValue) {
        [self.numberLabel setText:[NSString stringWithFormat:@"%i-%i+", (int)self.rangeSlider.leftValue, (int)self.rangeSlider.rightValue - 1]];
    } else {
        [self.numberLabel setText:[NSString stringWithFormat:@"%i-%i", (int)self.rangeSlider.leftValue, (int)self.rangeSlider.rightValue]];
    }
}

@end
