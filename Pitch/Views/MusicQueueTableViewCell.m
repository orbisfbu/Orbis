//
//  MusicQueueTableViewCell.m
//  Pitch
//
//  Created by mariobaxter on 8/5/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MusicQueueTableViewCell.h"

@implementation MusicQueueTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)likeButtonPressed:(id)sender {
    if (self.userDoesLike) {
        [self.likeButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        [self.numLikesLabel setText:[NSString stringWithFormat:@"%i", [self.numLikesLabel.text intValue] - 1]];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
        [self.numLikesLabel setText:[NSString stringWithFormat:@"%i", [self.numLikesLabel.text intValue] + 1]];
    }
    self.userDoesLike = !self.userDoesLike;
}

@end
