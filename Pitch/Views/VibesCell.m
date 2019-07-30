//
//  VibesCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "VibesCell.h"
#import "Vibes.h"
#import "CustomCollectionViewCell.h"

@interface VibesCell ()
@property (strong, nonatomic) NSArray *vibesArray;
@end

@implementation VibesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.vibesCollectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CustomCollectionViewCell"];
    self.vibesCollectionView.dataSource = self;
    self.vibesCollectionView.delegate = self;
    self.vibesArray = [[Vibes sharedVibes] getVibesArray];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [self.vibesCollectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionViewCell" forIndexPath:indexPath];
    [cell setLabelText:self.vibesArray[indexPath.item]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.vibesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"CustomCollectionViewCell" owner:self options:nil].firstObject;
    [cell setLabelText:self.vibesArray[indexPath.row]];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return CGSizeMake(size.width, 30);
}

@end
