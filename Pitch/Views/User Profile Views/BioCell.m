//
//  BioCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "BioCell.h"
#import "UserInSession.h"

@implementation BioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [self.userBioLabel setText:[UserInSession shared].sharedUser.userBioString];
    self.userBioLabel.text = [NSString stringWithFormat: @"This is what a user bio would look like!"];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
