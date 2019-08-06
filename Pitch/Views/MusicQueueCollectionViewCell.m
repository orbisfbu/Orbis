//
//  MusicQueueCollectionViewCell.m
//  Pitch
//
//  Created by mariobaxter on 8/2/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MusicQueueCollectionViewCell.h"

@implementation MusicQueueCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) initWithSong:(Song *) song {
    [self.albumImageView setImage:[UIImage imageNamed:song.albumName]];
    [self.artistNameLabel setText:song.artistName];
    [self.nameLabel setText:song.title];
}

@end
