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
#import "ApplyFiltersCell.h"
#import "DragCell.h"


@interface ExploreViewController () <UITableViewDelegate, UITableViewDataSource, DataHandlingDelegate, MKMapViewDelegate, CLLocationManagerDelegate, ApplyFiltersDelegate>

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
@property (strong, nonatomic) VibesCell *vibesCell;
@property (strong, nonatomic) DistanceCell *distanceCell;
@property (strong, nonatomic) NumberOfPeopleCell *numberOfPeopleCell;
@property (strong, nonatomic) AgeCell *ageCell;
@property (strong, nonatomic) ApplyFiltersCell *applyFiltersCell;

@property BOOL isScrollingTVUp;

@end

@implementation ExploreViewController

- (void)viewDidAppear:(BOOL)animated {
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
    [self.dropDownFilterTV setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.dropDownFilterTV setScrollEnabled:YES];
    [self.dropDownFilterTV setShowsVerticalScrollIndicator:NO];
    [self.view insertSubview:self.dropDownFilterTV belowSubview:self.searchBar];
    self.dropDownFilterTV.delegate = self;
    self.dropDownFilterTV.dataSource = self;
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"DistanceCell" bundle:nil] forCellReuseIdentifier:@"DistanceCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"AgeCell" bundle:nil] forCellReuseIdentifier:@"AgeCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"NumberOfPeopleCell" bundle:nil] forCellReuseIdentifier:@"NumberOfPeopleCell"];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"ApplyFiltersCell" bundle:nil] forCellReuseIdentifier:@"ApplyFiltersCell"];
    [self.dropDownFilterTV setAllowsSelection:NO];
    [self.dropDownFilterTV registerNib:[UINib nibWithNibName:@"DragCell" bundle:nil] forCellReuseIdentifier:@"DragCell"];
    [self.dropDownFilterTV setAllowsSelection:NO];
    //[self.dropDownFilterTV setRowHeight:UITableViewAutomaticDimension];
    
    self.isScrollingTVUp = NO;
}


- (void)refreshEventsData {
    [self.dataHandlingObject getEventsArray];
}

- (void)populateMapWithEvents {
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
    [self.dropDownFilterTV setScrollEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        [self.filterButton setTransform:CGAffineTransformMakeRotation((CGFloat)0)];
        self.dropDownFilterTV.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 18, self.searchBar.frame.size.width - 35, 0);
    } completion:^(BOOL finished) {
        [self.dropDownFilterTV setScrollEnabled:YES];
    }];
}

- (void) addFilterMenu {
    [self.dropDownFilterTV setScrollEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        [self.filterButton setTransform:CGAffineTransformMakeRotation((CGFloat)M_PI_2)];
        self.dropDownFilterTV.frame = CGRectMake(self.searchBar.frame.origin.x + 15, self.searchBar.frame.origin.y + self.searchBar.frame.size.height - 18, self.searchBar.frame.size.width - 35, 450);
    } completion:^(BOOL finished) {
        [self.dropDownFilterTV setScrollEnabled:YES];
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
    if (indexPath.row == 0) {
        self.vibesCell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"VibesCell"];
        [self.vibesCell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        [self.vibesCell awakeFromNib];
        return self.vibesCell;
    } else if (indexPath.row == 1) {
        self.distanceCell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"DistanceCell"];
        [self.distanceCell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        return self.distanceCell;
    } else if (indexPath.row == 2) {
        self.numberOfPeopleCell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"NumberOfPeopleCell"];
        [self.numberOfPeopleCell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        return self.numberOfPeopleCell;
    } else if (indexPath.row == 3){
        self.ageCell = [self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"AgeCell"];
        [self.ageCell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        return self.ageCell;
    } else if (indexPath.row == 4){
        self.applyFiltersCell = (ApplyFiltersCell *)[self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"ApplyFiltersCell"];
        [self.applyFiltersCell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        self.applyFiltersCell.delegate = self;
        return self.applyFiltersCell;
    } else {
        DragCell *cell = (DragCell *)[self.dropDownFilterTV dequeueReusableCellWithIdentifier:@"DragCell"];
        [cell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0) {
        if (scrollView.contentOffset.y > 0) {
            self.isScrollingTVUp = YES;
        } else {
            self.isScrollingTVUp = NO;
        }
    }
    if (self.dropDownFilterTV.frame.size.height - scrollView.contentOffset.y > 0) {
        self.dropDownFilterTV.frame = CGRectMake(self.dropDownFilterTV.frame.origin.x, self.dropDownFilterTV.frame.origin.y, self.dropDownFilterTV.frame.size.width, self.dropDownFilterTV.frame.size.height - scrollView.contentOffset.y);
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isScrollingTVUp) {
        [self removeFilterMenu];
    } else {
        [self addFilterMenu];
    }
    self.filterMenuIsShowing = !self.filterMenuIsShowing;
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

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *crnLoc = [locations lastObject];
    NSString *mylatitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    NSString *myLongitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
}

- (void)applyFiltersButtonWasPressed {
    NSLog(@"Applying Filters...");
    [self filterAnnotations];
}

- (void)resetFiltersButtonWasPressed {
    NSLog(@"Resetting Filters...");
    [self.vibesCell resetVibes];
    [self.distanceCell resetDistance];
    [self.numberOfPeopleCell resetNumberOfPeople];
    [self.ageCell resetAgeRestrictions];
    [self filterAnnotations];
}

- (void) filterAnnotations {
    
    int ageRestriction = [self.ageCell getAgeRestrictions];
    NSMutableSet *vibesSet = [self.vibesCell getSelectedVibes];
    int distance = [self.distanceCell getDistance];
    int minNumPeople = [self.numberOfPeopleCell getMinNumPeople];
    int maxNumPeople = [self.numberOfPeopleCell getMaxNumPeople];
    
    // Filter array of events
    
    // Refresh map
}

@end
