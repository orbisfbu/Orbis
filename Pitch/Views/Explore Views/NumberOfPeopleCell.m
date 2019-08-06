//
//  NumberOfPeopleCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "NumberOfPeopleCell.h"
#import "Filters.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static int const DEFAULT_LEFT_PEOPLE = 10;
static int const DEFAULT_RIGHT_PEOPLE = 100;
static int const DEFAULT_MAX_PEOPLE = 501;
static int const DEFAULT_MIN_PEOPLE = 1;

@interface NumberOfPeopleCell ()
@property (strong, nonatomic) Filters *filter;
@property int minNumPeople;
@property int maxNumPeople;
@end

@implementation NumberOfPeopleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.filter = [Filters sharedFilters];
    self.subview.layer.cornerRadius = 5;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.numberLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    self.rangeSlider = [[MARKRangeSlider alloc] initWithFrame:CGRectMake(5, 5, self.subview.frame.size.width - 10, self.subview.frame.size.height - 10)];
    [self.rangeSlider addTarget:self action:@selector(rangeSliderValueDidChange:)
               forControlEvents:UIControlEventValueChanged];
    [self.rangeSlider setMinValue:DEFAULT_MIN_PEOPLE maxValue:DEFAULT_MAX_PEOPLE];
    [self.rangeSlider setLeftValue:DEFAULT_LEFT_PEOPLE rightValue:DEFAULT_RIGHT_PEOPLE];
    
    NSArray *arrayOfImages = self.rangeSlider.subviews;
    UIImageView *imageView = arrayOfImages[1];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageView setTintColor: UIColorFromRGB(0x137b5b)];
    
    [self.subview addSubview:self.rangeSlider];
    self.maxNumPeople = INFINITY;
    self.minNumPeople = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)rangeSliderValueDidChange:(MARKRangeSlider *)slider {
    if (slider.rightValue == slider.maximumValue) {
        [self.numberLabel setText:[NSString stringWithFormat:@"%i-%i+", (int)self.rangeSlider.leftValue, (int)self.rangeSlider.rightValue - 1]];
//        [self.filter setMaxNumPeople:INFINITY];
        self.maxNumPeople = INFINITY;
    } else {
        [self.numberLabel setText:[NSString stringWithFormat:@"%i-%i", (int)self.rangeSlider.leftValue, (int)self.rangeSlider.rightValue]];
//        [self.filter setMaxNumPeople:self.rangeSlider.rightValue];
        self.maxNumPeople = self.rangeSlider.rightValue;
    }
//    [self.filter setMinNumPeople:self.rangeSlider.leftValue];
    self.minNumPeople = self.rangeSlider.leftValue;
}

- (void) resetNumberOfPeople {
    [self.rangeSlider setLeftValue:DEFAULT_LEFT_PEOPLE rightValue:DEFAULT_RIGHT_PEOPLE];
    [self.numberLabel setText:[NSString stringWithFormat:@"%i-%i", (int)self.rangeSlider.leftValue, (int)self.rangeSlider.rightValue]];
//    [self.filter setMaxNumPeople:self.rangeSlider.rightValue];
//    [self.filter setMinNumPeople:self.rangeSlider.leftValue];
    self.maxNumPeople = self.rangeSlider.rightValue;
    self.minNumPeople = self.rangeSlider.leftValue;
}

- (int) getMinNumPeople {
    return self.minNumPeople;
}

- (int) getMaxNumPeople {
    return self.maxNumPeople;
}

@end
