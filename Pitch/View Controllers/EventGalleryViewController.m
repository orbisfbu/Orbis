//
//  EventGalleryViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventGalleryViewController.h"

@interface EventGalleryViewController ()

@end

@implementation EventGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.roundedCornersView.layer.cornerRadius = 30;
    self.roundedCornersView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
