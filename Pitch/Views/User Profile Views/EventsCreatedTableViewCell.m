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
#import "DataHandling.h"

@implementation EventsCreatedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"EventsCollectionViewCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
//    [[DataHandling shared] getEventsCreatedByUserWithCompletion:^(NSMutableArray * _Nonnull createdEventsByUserArray) {
//        self.eventsCreatedByUserMArray = createdEventsByUserArray;
//
//    }];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    long row = indexPath.item%3+1;
    NSString *imageName = [NSString stringWithFormat:@"example_event_%lu", row];
    EventsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventsCollectionViewCell" forIndexPath:indexPath];
    [cell.eventImage setImage:[UIImage imageNamed:imageName]];
    
    // set user profile image in data handling
    // set event image URL string based on
    // event you want to load is based on index path
    
    ///////////////NEW STUFF
//    NSLog(@"THIS IS THE SIZE OF THE EVENTS ATTENDED ARRAY: %lu", [UserInSession shared].attendedEventsByUserArray.count);
//    Event *attendedEventForCell = [UserInSession shared].attendedEventsByUserArray[indexPath.item];
//    NSString *attendedEventImageURLString = attendedEventForCell.eventImageURLString;
//    [cell.eventImage setImageWithURL:[NSURL URLWithString:attendedEventImageURLString] placeholderImage:[UIImage imageNamed:@"eventImage"]];
    ///////////////NEW STUFF
    
    cell.layer.cornerRadius = 10;
    return cell;

}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%d",[UserInSession shared].createdEventsByUserArray.count);
    return [UserInSession shared].createdEventsByUserArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventsCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"EventsCollectionViewCell" owner:self options:nil].firstObject;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return CGSizeMake(100, 150);
}


//- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    long row = indexPath.item%3 + 1;
//    NSString *imageName = [NSString stringWithFormat:@"example_event_%lu", row];
//    EventsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventsCollectionViewCell" forIndexPath:indexPath];
//    [cell.eventImage setImage:[UIImage imageNamed:imageName]];
//    cell.layer.cornerRadius = 10;
//    return cell;
//}
//
//- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 10;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    EventsCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"EventsCollectionViewCell" owner:self options:nil].firstObject;
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
//    return CGSizeMake(100, 150);
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}

@end
