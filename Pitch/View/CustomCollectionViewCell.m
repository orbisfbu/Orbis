//
//  CustomCollectionViewCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 12;
}

- (void) setLabelText:(NSString *)text {
    self.titleLabel.text = text;
}

@end
