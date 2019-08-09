//
//  EventGalleryViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventGalleryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *clickableMapView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *swipeIndicatorView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Event *event;
@end

NS_ASSUME_NONNULL_END
