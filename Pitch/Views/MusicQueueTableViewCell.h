//
//  MusicQueueTableViewCell.h
//  Pitch
//
//  Created by mariobaxter on 8/5/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicQueueTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;


@property BOOL userDoesLike;
@property (strong, nonatomic) NSString *eventID;
@property long index;
@property (strong, nonatomic) Song *song;
@end

NS_ASSUME_NONNULL_END
