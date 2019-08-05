//
//  MusicQueueViewController.h
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicQueueViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *clickableMapView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *swipeIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addSongButton;
@property (nonatomic) BOOL isRegistered;
@end

NS_ASSUME_NONNULL_END
