//
//  ExploreViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "ExploreViewController.h"
#import <MapKit/MapKit.h>
#import "VibesCell.h"
#import "DistanceCell.h"
#import "NumberOfPeopleCell.h"
#import "AgeCell.h"
#import "Event.h"
#import "Datahandling.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ExploreViewController () <UITableViewDelegate, UITableViewDataSource, DataHandlingDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *photoMap;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (nonatomic) BOOL filterMenuIsShowing;
@property (strong, nonatomic) UITableView *dropDownFilterTV;
@property (strong, nonatomic) NSMutableArray <Event *> *eventsArray;
@property (strong, nonatomic) DataHandling *dataHandlingObject;
@end

@implementation ExploreViewController


- (void)viewDidAppear:(BOOL)animated {
    [self refreshEventsData];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.dataHandlingObject = [DataHandling shared];
    self.dataHandlingObject.delegate = self;
    [self refreshEventsData];

    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.photoMap setRegion:sfRegion animated:false];
    //self.photoMap.delegate = self;
    // Eliminate the gray background color of the search bar
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    // Add tap recognizer to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardAndRemoveFilters)];
    [self.photoMap addGestureRecognizer:tap];
    
    // Set the filterMenuIsShowing BOOL to false
    self.filterMenuIsShowing = NO;
    
    // Set the delegate and datasource of the drop down table view
    CGRect frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 18, self.searchBar.frame.size.width - 30, 0);
    self.dropDownFilterTV = [[UITableView alloc] initWithFrame:frame];
    self.dropDownFilterTV.layer.cornerRadius = 10;
    [self.dropDownFilterTV setBackgroundColor:UIColorFromRGB(0xc2f5e6)];
    [self.dropDownFilterTV setScrollEnabled:NO];
    [self.view insertSubview:self.dropDownFilterTV belowSubview:self.searchBar];
    self.dropDownFilterTV.delegate = self;
    self.dropDownFilterTV.dataSource = self;
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"DistanceCell" bundle:nil] forCellReuseIdentifier:@"DistanceCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"AgeCell" bundle:nil] forCellReuseIdentifier:@"AgeCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"NumberOfPeopleCell" bundle:nil] forCellReuseIdentifier:@"NumberOfPeopleCell"];
    [self.dropDownFilterTV setAllowsSelection:NO];
    //[self.dropDownFilterTV setRowHeight:UITableViewAutomaticDimension];
}


- (void)refreshEventsData
{
    [self.dataHandlingObject getEventsArray];
}


- (void)populateMapWithEvents
{
    if (self.eventsArray.count > 0)
    {
        for (Event *thisEvent in self.eventsArray)
        {
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = thisEvent.eventCoordinates;
            annotation.title = thisEvent.eventName;
            [self.photoMap addAnnotation:annotation];
        }
    }
}


- (void) dismissKeyboardAndRemoveFilters {
    [self.view endEditing:YES];
    [self removeFilterMenu];
    self.filterMenuIsShowing = NO;
}

- (void) removeFilterMenu {
    [UIView animateWithDuration:0.5 animations:^{
        [self.filterButton setTransform:CGAffineTransformMakeRotation((CGFloat)0)];
        self.dropDownFilterTV.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 18, self.searchBar.frame.size.width - 35, 0);
    }];
}

- (void) addFilterMenu {
    [UIView animateWithDuration:0.5 animations:^{
        [self.filterButton setTransform:CGAffineTransformMakeRotation((CGFloat)M_PI_2)];
        self.dropDownFilterTV.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 18, self.searchBar.frame.size.width - 35, 2*self.view.frame.size.height/3);
    }];
}

- (IBAction) filterButtonPressed:(id)sender {
    if (!self.filterMenuIsShowing) {
        [self addFilterMenu];
    } else {
        [self removeFilterMenu];
    }
    self.filterMenuIsShowing = !self.filterMenuIsShowing;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"VibesCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 1) {
        cell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"DistanceCell"];
    } else if (indexPath.row == 2) {
        cell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"NumberOfPeopleCell"];
    } else {
        cell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"AgeCell"];
    }
    [cell setBackgroundColor:UIColorFromRGB(0xc2f5e6)];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


- (void)updateEvents:(nonnull NSArray *)events {
    self.eventsArray = [NSMutableArray arrayWithArray:events];
    //NSLog(@"--Size of events array is: %i--", events.count);
    [self populateMapWithEvents];
}


@end
