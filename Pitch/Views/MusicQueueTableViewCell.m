//
//  MusicQueueTableViewCell.m
//  Pitch
//
//  Created by mariobaxter on 8/5/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MusicQueueTableViewCell.h"
#import "DataHandling.h"

@interface MusicQueueTableViewCell ()

@property (strong, nonatomic) DataHandling *dataHandler;

@end

@implementation MusicQueueTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dataHandler = [DataHandling shared];
    [self.artistNameLabel setText:self.song.artistName];
    [self.songNameLabel setText:self.song.title];
    [self.numLikesLabel setText:[NSString stringWithFormat:@"%ld", self.song.numLikes]];
    if ([self.song.userIDsThatHaveLikedSong containsObject:[FIRAuth auth].currentUser.uid]) {
        [self.likeButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)likeButtonPressed:(id)sender {
    if ([self.song.userIDsThatHaveLikedSong containsObject:[FIRAuth auth].currentUser.uid]) {
        [self.likeButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        [self.numLikesLabel setText:[NSString stringWithFormat:@"%i", [self.numLikesLabel.text intValue] - 1]];
        [self.dataHandler user:[FIRAuth auth].currentUser.uid didUnlikeSong:self.song atIndex:self.index atEvent:self.eventID];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
        [self.numLikesLabel setText:[NSString stringWithFormat:@"%i", [self.numLikesLabel.text intValue] + 1]];
        [self.dataHandler user:[FIRAuth auth].currentUser.uid didLikeSong:self.song atIndex:self.index atEvent:self.eventID];
    }
}

@end
