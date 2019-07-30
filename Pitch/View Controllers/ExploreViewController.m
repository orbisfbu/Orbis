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
#import "DataHandling.h"
#import "UIImageView+AFNetworking.h"
#import "EventAnnotation.h"
#import "EventDetailsViewController.h"


@interface ExploreViewController () <UITableViewDelegate, UITableViewDataSource, DataHandlingDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@property (weak, nonatomic) IBOutlet MKMapView *photoMap;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (nonatomic) BOOL filterMenuIsShowing;
@property (strong, nonatomic) UITableView *dropDownFilterTV;
@property (strong, nonatomic) NSMutableArray <Event *> *eventsArray;
@property (strong, nonatomic) DataHandling *dataHandlingObject;
@property (nonatomic, readwrite) FIRFirestore *db;
@end

@implementation ExploreViewController

- (void)viewDidAppear:(BOOL)animated
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager startUpdatingLocation];
    [self refreshEventsData];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.dataHandlingObject = [DataHandling shared];
    self.dataHandlingObject.delegate = self;
    self.photoMap.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.photoMap setShowsUserLocation:YES];
    #ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
    }
    #endif
    [self.locationManager startUpdatingLocation];
    //retrieve events from database
    [self refreshEventsData];
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.photoMap setRegion:sfRegion animated:false];
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
    [self.dropDownFilterTV setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
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
            //set the rest of the properties here
            //will have to pass in this information to the modal that will be presented as a result of click
            EventAnnotation *newEventAnnotation = [[EventAnnotation alloc] init];
            newEventAnnotation.coordinate = thisEvent.eventCoordinates;
            newEventAnnotation.eventName = thisEvent.eventName;
            newEventAnnotation.eventCreator = thisEvent.eventCreator;
            newEventAnnotation.eventDescription = thisEvent.eventDescription;
            newEventAnnotation.eventAgeRestriction = thisEvent.eventAgeRestriction;
            newEventAnnotation.eventAttendanceCount = thisEvent.eventAttendanceCount;
            [self.photoMap addAnnotation:newEventAnnotation];
        }
    }
}

- (void)dismissEventDetails:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)presentEventDetailsView: (EventAnnotation *)eventToPresent
{
    UIStoryboard *detailsSB = [UIStoryboard storyboardWithName:@"EventDetails" bundle:nil];
    EventDetailsViewController * detailedEventVC = (EventDetailsViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"Details"];
    detailedEventVC.eventNameLabel.text = eventToPresent.eventName;
    detailedEventVC.eventCreatorLabel.text = eventToPresent.eventCreator;
    detailedEventVC.eventDescription.text = eventToPresent.eventDescription;
    detailedEventVC.eventImageView.image = eventToPresent.eventImage;
    
    detailedEventVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    detailedEventVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:detailedEventVC animated:YES completion:nil];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEventDetails:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [detailedEventVC.view addGestureRecognizer: downGestureRecognizer];
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
        self.dropDownFilterTV.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 18, self.searchBar.frame.size.width - 35, 456);
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
    [cell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
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
    [self populateMapWithEvents];
}


- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    NSString *annotationIdentifier = @"Event";
    MKPinAnnotationView *newEventAnnotationView = (EventAnnotation*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (newEventAnnotationView == nil) {
        newEventAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        newEventAnnotationView.canShowCallout = NO;
    }
    //[newEventAnnotationView addSubview:[[UIImageView alloc] initWithImage:newEventAnnotationView.eventImage]];
    return newEventAnnotationView;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:YES];
    [self presentEventDetailsView:view.annotation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *crnLoc = [locations lastObject];
    NSString *mylatitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    NSString *myLongitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
    NSLog(mylatitude);
    NSLog(myLongitude);
}

@end
