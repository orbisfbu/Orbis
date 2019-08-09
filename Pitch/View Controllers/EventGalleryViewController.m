//
//  EventGalleryViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventGalleryViewController.h"
#import "EventGalleryCell.h"
#import "UIImageView+AFNetworking.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EventGalleryViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray <NSString *> *imageURLStringsArray;
@end

@implementation EventGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageURLStringsArray = @[@"https://bit.ly/2Ta1Tex",@"https://bit.ly/2GQJ0sa",@"https://washington-org.s3.amazonaws.com/s3fs-public/crowded_show_at_930_club_credit_richie_downs.jpg",@"https://d1amsjpw70k1w5.cloudfront.net/l6hfsc63q612/7GSZkhZuR4Ji0LfX6ps54D/b07d95e78688e45163d5781852d822de/0013_180812-005511-TheQontinent-KEVIN-6250-DNG-Edit.jpg?w=1024",@"https://d49r1np2lhhxv.cloudfront.net/www/admin/uploads/images/ImagineEDMPic.jpg",@"https://upload.wikimedia.org/wikipedia/commons/f/f1/Ultra_Stage.jpg"];
    
    // Set up Title View
    self.titleView.layer.cornerRadius = 30;
    self.titleView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    self.swipeIndicatorView.layer.cornerRadius = self.swipeIndicatorView.frame.size.height/2;
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [self.clickableMapView addGestureRecognizer:tapMap];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.titleView addGestureRecognizer: downGestureRecognizer];
    
    // Set up Collection View
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5.0;
    layout.minimumLineSpacing = 5.0;
    CGFloat imagesPerLine = 3;
    CGFloat itemWidth = ([[UIScreen mainScreen] bounds].size.width - layout.minimumInteritemSpacing * (imagesPerLine - 1)) / imagesPerLine;
    [layout setItemSize:CGSizeMake(itemWidth, itemWidth)];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventGalleryCell" bundle:nil] forCellWithReuseIdentifier:@"EventGalleryCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EventGalleryCell" forIndexPath:indexPath];
    NSURL *imageNSURL = [NSURL URLWithString:self.imageURLStringsArray[indexPath.item]];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageNSURL];
    [cell.imageView setImageWithURL:imageNSURL];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageURLStringsArray.count;
}

-(void)dismissTabBarModal:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
