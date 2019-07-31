//
//  FirstLastNameCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "FirstLastNameCell.h"
#import "UserInSession.h"

@implementation FirstLastNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fullNameLabel.text = [UserInSession shared].sharedUser.userNameString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
