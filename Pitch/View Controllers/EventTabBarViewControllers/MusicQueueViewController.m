//
//  MusicQueueViewController.m
//  Pitch
//
//  Created by sbernal0115 on 7/29/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MusicQueueViewController.h"

@interface MusicQueueViewController ()

@end

@implementation MusicQueueViewController

- (void)viewDidLoad {
    self.roundedCornersView.layer.cornerRadius = 30;
    self.roundedCornersView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
