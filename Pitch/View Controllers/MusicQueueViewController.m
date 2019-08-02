//
//  MusicQueueViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MusicQueueViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MusicQueueViewController ()

@end

@implementation MusicQueueViewController

- (void)viewDidLoad {
    [self configureInitialViewsAndGestures];
}

- (void)configureInitialViewsAndGestures{
    
    
    self.roundedCornersViewOutlet.layer.cornerRadius = 30;
    self.roundedCornersViewOutlet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.scrollViewOutlet.clipsToBounds = YES;
    self.queueSectionTitleLabel.layer.cornerRadius = 30;
    self.swipeIndicatorOutlet.layer.cornerRadius = self.swipeIndicatorOutlet.frame.size.height/2;
    self.queueSectionTabOutlet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    [self.scrollViewOutlet setShowsVerticalScrollIndicator:NO];
    self.scrollViewOutlet.contentSize = CGSizeMake(self.view.frame.size.width, self.roundedCornersViewOutlet.frame.size.height + 500);
    [self.swipeIndicatorOutlet setBackgroundColor:[UIColor lightGrayColor]];
    [self.queueSectionTitleLabel setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    self.roundedCornersViewOutlet.backgroundColor = UIColorFromRGB(0x21ce99);
    self.scrollViewOutlet.contentInsetAdjustmentBehavior = 2;
    [super viewDidLoad];
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [self.clickableMapViewOutlet addGestureRecognizer:tapMap];
    
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.queueSectionTabOutlet addGestureRecognizer: downGestureRecognizer];
    
}


-(void)dismissTabBarModal:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
