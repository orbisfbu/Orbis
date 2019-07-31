//
//  DragCell.m
//  Pitch
//
//  Created by mariobaxter on 7/30/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DragCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation DragCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dragView.layer.cornerRadius = self.dragView.frame.size.height/2;
    [self.dragView setBackgroundColor:[UIColor lightGrayColor]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
