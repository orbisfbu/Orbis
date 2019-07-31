//
//  LogoutCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "LogoutCell.h"

@implementation LogoutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.button.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)userPressedLogout:(id)sender {
    [self.delegate logoutUser];
}

@end
