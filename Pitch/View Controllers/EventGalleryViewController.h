//
//  EventGalleryViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventGalleryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *clickableMapViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *galleryTitleView;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *galleryTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *swipeIndicatorOutlet;
@property (strong, nonatomic) NSArray <NSString *> *imageURLStringsArray;
@end

NS_ASSUME_NONNULL_END
