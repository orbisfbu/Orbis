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
#import "Filters.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface VibesCell ()
@property (strong, nonatomic) NSArray *vibesArray;
@property (strong, nonatomic) NSMutableSet *selectedVibesSet;
@property (strong, nonatomic) Filters *filter;
@end

@implementation VibesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.filter = [Filters sharedFilters];
    self.subview.layer.cornerRadius = 5;
    [self.vibesCollectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CustomCollectionViewCell"];
    [self.vibesCollectionView setAllowsMultipleSelection:YES];
    self.vibesCollectionView.dataSource = self;
    self.vibesCollectionView.delegate = self;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    self.vibesArray = [[Vibes sharedVibes] getVibesArray];
    self.selectedVibesSet = [[NSMutableSet alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/////////////////////////////////////
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
///////////////////////////////////////

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3 animations:^{
        cell.frame = CGRectMake(cell.frame.origin.x - 5, cell.frame.origin.y - 2.5, cell.frame.size.width + 10, cell.frame.size.height + 5);
    }];
    [cell setBackgroundColor:UIColorFromRGB(0x137b5b)];
    [cell.titleLabel setTextColor:UIColorFromRGB(0xffffff)];
//    [cell setLabelText:UIColorFromRGB(0xffffff)];
    [self.selectedVibesSet addObject:cell.titleLabel.text];
    [self.filter setSelectedVibes:[NSMutableArray arrayWithObjects:[self.selectedVibesSet allObjects], nil]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3 animations:^{
        cell.frame = CGRectMake(cell.frame.origin.x + 5, cell.frame.origin.y + 2.5, cell.frame.size.width - 10, cell.frame.size.height - 5);
    }];
//    [cell setBackgroundColor:UIColorFromRGB(0x21ce99)];
    [cell setBackgroundColor:UIColorFromRGB(0x90e6cc)];
    [cell.titleLabel setTextColor:UIColorFromRGB(0x000000)];
    [self.selectedVibesSet removeObject:cell.titleLabel.text];
    [self.filter setSelectedVibes:[NSMutableArray arrayWithObjects:[self.selectedVibesSet allObjects], nil]];
}

- (void) resetVibes {
    NSArray *pathArray = [self.vibesCollectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in pathArray) {
        [self.vibesCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.3 animations:^{
            cell.frame = CGRectMake(cell.frame.origin.x + 5, cell.frame.origin.y + 2.5, cell.frame.size.width - 10, cell.frame.size.height - 5);
        }];
        [cell setBackgroundColor:UIColorFromRGB(0x90e6cc)];
        [cell.titleLabel setTextColor:UIColorFromRGB(0x000000)];
        [self.selectedVibesSet removeObject:cell.titleLabel.text];
    }
    [self.filter setSelectedVibes:[NSMutableArray arrayWithObjects:[self.selectedVibesSet allObjects], nil]];
}

- (NSMutableSet *) getSelectedVibes {
    return self.selectedVibesSet;
}

@end
