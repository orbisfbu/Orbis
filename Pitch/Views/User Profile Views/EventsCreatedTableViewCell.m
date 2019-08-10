//
//  EventListCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventsCreatedTableViewCell.h"
#import "EventsCollectionViewCell.h"
#import "UserInSession.h"
#import <UIImageView+AFNetworking.h>

@implementation EventsCreatedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"EventsCollectionViewCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    long row = indexPath.item%3 + 1;
//    NSString *imageName = [NSString stringWithFormat:@"example_event_%lu", row];
//    EventsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventsCollectionViewCell" forIndexPath:indexPath];
//    // set user profile image in data handling
//    // set event image URL string based on
//    // event you want to load is based on index path
//    // Event *eventForCell = [UserInSession shared].createdEvents[indexPath.row]
//
//    [cell.eventImage setImage:[UIImage imageNamed:imageName]];
//    cell.layer.cornerRadius = 10;
//    return cell;
//}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventsCollectionViewCell" forIndexPath:indexPath];
//    NSString *imageName = [NSString stringWithFormat:@"example_event_%lu", row];
//    EventsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventsCollectionViewCell" forIndexPath:indexPath];
    // set user profile image in data handling
    // set event image URL string based on
    // event you want to load is based on index path
    if ([UserInSession shared].createdEventsByUserArray.count == 0){
        [cell.eventImage setImage:([UIImage imageNamed:@"eventImage"])];
    }
    else {
        Event *createdEventForCell = [UserInSession shared].createdEventsByUserArray[indexPath.row];
        NSString *createdEventImageURLString = createdEventForCell.eventImageURLString;
        [cell.eventImage setImageWithURL:[NSURL URLWithString:createdEventImageURLString] placeholderImage:[UIImage imageNamed:@"eventImage"]];
        // [createdEventForCell.eventImageURLString setImage:[UIImage imageNamed:imageName]];
    }
    cell.layer.cornerRadius = 10;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventsCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"EventsCollectionViewCell" owner:self options:nil].firstObject;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return CGSizeMake(100, 150);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

@end
