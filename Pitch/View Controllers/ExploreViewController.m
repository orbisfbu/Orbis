//
//  ExploreViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "ExploreViewController.h"
#import <MapKit/MapKit.h>

@interface ExploreViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *photoMap;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.photoMap setRegion:sfRegion animated:false];
    //self.photoMap.delegate = self;
    
    // Eliminate the gray background color of the search bar
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    
    // Add tap recognizer to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardAndRemoveFilters)];
    //UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.photoMap action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    //[self.photoMap addGestureRecognizer:pan];
}

- (void)dismissKeyboardAndRemoveFilters {
    [self.view endEditing:YES];
    for (UIView *view in [self.photoMap subviews]) {
        if ([[view accessibilityIdentifier] isEqualToString:@"dropDownMenuView"]) {
            NSLog(@"Removing view...");
            [UIView animateWithDuration:0.5 animations:^{
                view.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 20, self.searchBar.frame.size.width - 35, 0);
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }
    }
}

- (IBAction)filterButtonPressed:(id)sender {
    
    //NSLog(@"%lu", self.view.frame.origin.x);
    //NSLog(@"%lu", self.searchBar.frame.origin.x);
    
    CGRect filterFrame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 20, self.searchBar.frame.size.width - 35, 0);
    UIView *filterView = [[UIView alloc] initWithFrame:filterFrame];
    filterView.layer.cornerRadius = 10;
    filterView.backgroundColor = [UIColor whiteColor];
    [filterView setAccessibilityIdentifier:@"dropDownMenuView"];
    [self.photoMap addSubview:filterView];
    
    [UIView animateWithDuration:0.5 animations:^{
        filterView.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 20, self.searchBar.frame.size.width - 35, 2*self.view.frame.size.height/3);
    }];
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
