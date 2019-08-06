//
//  DistanceCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DistanceCell.h"
#import "Filters.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static int const DEFAULT_DISTANCE = 5;
static int const MAX_DISTANCE = 50;
static int const MIN_DISTANCE = 1;

@interface DistanceCell ()
@property (strong, nonatomic) Filters *filter;
@property int currentDistance;
@end

@implementation DistanceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.filter = [Filters sharedFilters];
    self.subview.layer.cornerRadius = 5;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.distanceLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.slider setMaximumValue:MAX_DISTANCE];
    [self.slider setMinimumValue:MIN_DISTANCE];
    [self.slider setValue:DEFAULT_DISTANCE];
    [self.slider setMinimumTrackTintColor:UIColorFromRGB(0x157f5f)];
    self.currentDistance = INFINITY;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)sliderDidSlide:(id)sender {
    [self.distanceLabel setText:[NSString stringWithFormat:@"%i km", (int)self.slider.value]];
//    [self.filter setDistance:self.slider.value];
    self.currentDistance = self.slider.value;
}

- (void) resetDistance {
    self.slider.value = DEFAULT_DISTANCE;
    [self.distanceLabel setText:[NSString stringWithFormat:@"%i km", (int)self.slider.value]];
//    [self.filter setDistance:self.slider.value];
    self.currentDistance = self.slider.value;
}

- (int) getDistance {
    return self.currentDistance;
}

@end
