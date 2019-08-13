//
//  EventListCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventListCell.h"
#import "EventsCollectionViewCell.h"

@implementation EventListCell

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

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    long row = indexPath.item%3+1;
    NSString *imageName = [NSString stringWithFormat:@"random%lu", row];
    EventsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EventsCollectionViewCell" forIndexPath:indexPath];
    [cell.eventImage setImage:[UIImage imageNamed:imageName]];
    cell.layer.cornerRadius = 10;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
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
