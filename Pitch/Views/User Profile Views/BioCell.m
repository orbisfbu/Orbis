//
//  BioCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "BioCell.h"

@implementation BioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.userBioLabel setText:@"This is an example bio that is been used for the purposes of showing how a bio would look like. 😏︎"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
