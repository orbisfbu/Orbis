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
#import "DataHandling.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EventGalleryViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray <UIImage *> *imagesArray;
@property (strong, nonatomic) DataHandling *datahandler;
@end

@implementation EventGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datahandler = [DataHandling shared];
    [self getImageURLs];
    
    // Set up Title View
    self.titleView.layer.cornerRadius = 30;
    self.titleView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    self.swipeIndicatorView.layer.cornerRadius = self.swipeIndicatorView.frame.size.height/2;
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController:)];
    [self.clickableMapView addGestureRecognizer:tapMap];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController:)];
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

- (void) getImageURLs {
    self.imagesArray = [[NSMutableArray alloc] init];
    [self.datahandler getNumberOfAdditionalMediaFilesFromEvent:self.event.ID withCompletion:^(int count) {
        for (int i = 0; i < count; i++) {
            [self.datahandler getImageURLFromEvent:self.event.ID atIndex:i withCompletion:^(UIImage * _Nonnull image) {
                [self.imagesArray addObject:image];
                [self.collectionView reloadData];
            }];
        }
    }];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EventGalleryCell" forIndexPath:indexPath];
    [cell.imageView setImage:self.imagesArray[indexPath.item]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArray.count;
}

-(void)dismissTabBarModal:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
