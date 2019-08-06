//
//  EventGalleryViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventGalleryViewController.h"
#import "EventGalleryCollectionViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EventGalleryViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation EventGalleryViewController

- (void)viewDidLoad {
    self.imageURLStringsArray = @[@"https://bit.ly/2Ta1Tex",@"https://bit.ly/2GQJ0sa",@"https://washington-org.s3.amazonaws.com/s3fs-public/crowded_show_at_930_club_credit_richie_downs.jpg",@"https://d1amsjpw70k1w5.cloudfront.net/l6hfsc63q612/7GSZkhZuR4Ji0LfX6ps54D/b07d95e78688e45163d5781852d822de/0013_180812-005511-TheQontinent-KEVIN-6250-DNG-Edit.jpg?w=1024",@"https://d49r1np2lhhxv.cloudfront.net/www/admin/uploads/images/ImagineEDMPic.jpg",@"https://upload.wikimedia.org/wikipedia/commons/f/f1/Ultra_Stage.jpg"];
    self.galleryTitleView.layer.cornerRadius = 30;
    self.galleryTitleView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    self.swipeIndicatorOutlet.layer.cornerRadius = self.swipeIndicatorOutlet.frame.size.height/2;
    [self.swipeIndicatorOutlet setBackgroundColor:[UIColor lightGrayColor]];
    [self.galleryTitleView setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    [super viewDidLoad];
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [self.clickableMapViewOutlet addGestureRecognizer:tapMap];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.galleryTitleView addGestureRecognizer: downGestureRecognizer];
    [self.galleryTitleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    [self.imageCollectionView setBackgroundColor: UIColorFromRGB(0x21ce99)];
    self.imageCollectionView.dataSource = self;
    self.imageCollectionView.delegate = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.imageCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    CGFloat imagesPerLine = 2;
    NSLog(@"THIS IS THE IMAGECOLLECTIONVIEW WIDTH: %f", self.imageCollectionView.frame.size.width);
    CGFloat itemWidth = (self.imageCollectionView.frame.size.width - layout.minimumInteritemSpacing * (imagesPerLine - 1)) / imagesPerLine;
    NSLog(@"THIS SHOULD BE THE ITEM WIDTH: %f", itemWidth);
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(100,100);
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventGalleryCollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
    NSURL *imageNSURL = [NSURL URLWithString:self.imageURLStringsArray[indexPath.item]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageNSURL];
    UIImage *eventImage = [UIImage imageWithData:imageData];
    imageCell.galleryPicImageView.image = nil;
    [imageCell.galleryPicImageView setImage:eventImage];
    return imageCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageURLStringsArray.count;
}

-(void)dismissTabBarModal:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake((self.imageCollectionView.frame.size.width/3)-20, 100);
//}

@end
