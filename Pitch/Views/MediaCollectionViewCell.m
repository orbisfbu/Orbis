//
//  MediaCollectionViewCell.m
//  Pitch
//
//  Created by mariobaxter on 8/7/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MediaCollectionViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


static NSInteger const LIGHT_GREEN = 0xd2f5ea;

@implementation MediaCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 5;
    [self setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
}

@end
