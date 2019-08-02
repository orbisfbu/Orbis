//
//  MusicQueueCollectionViewCell.h
//  Pitch
//
//  Created by mariobaxter on 8/2/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicQueueCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

- (void) initWithSong:(Song *) song;

@end

NS_ASSUME_NONNULL_END
