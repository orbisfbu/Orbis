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
#import "CreateEventViewController.h"
#import "MusicQueueViewController.h"
#import "EventGalleryViewController.h"
#import "ApplyFiltersCell.h"
#import "DragCell.h"
#import "CreateEventViewController.h"
#import "MusicQueueViewController.h"
#import "EventGalleryViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ExploreViewController () <UITableViewDelegate, UITableViewDataSource, DataHandlingDelegate, MKMapViewDelegate, CLLocationManagerDelegate, AddEventToMapDelegate, ApplyFiltersDelegate, EventInfoForAnnotationDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *photoMap;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (strong, nonatomic) Event* eventToLoad;
@property (nonatomic) BOOL filterMenuIsShowing;
@property (strong, nonatomic) UITableView *dropDownFilterTV;
@property (strong, nonatomic) NSMutableArray <Event *> *eventsArray;
@property (strong, nonatomic) NSMutableArray <Event *> *filteredEventsArray;
@property (strong, nonatomic) DataHandling *dataHandlingObject;
@property (nonatomic, readwrite) FIRFirestore *db;
@property (strong, nonatomic) VibesCell *vibesCell;
@property (strong, nonatomic) DistanceCell *distanceCell;
@property (strong, nonatomic) NumberOfPeopleCell *numberOfPeopleCell;
@property (strong, nonatomic) AgeCell *ageCell;
@property (strong, nonatomic) ApplyFiltersCell *applyFiltersCell;
@property BOOL isScrollingTVUp;
@property BOOL filtersWereSet;

@end

@implementation ExploreViewController

- (void)viewDidAppear:(BOOL)animated
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager startUpdatingLocation];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.filtersWereSet = NO;
    self.dataHandlingObject = [DataHandling shared];
    self.dataHandlingObject.delegate = self;
    self.dataHandlingObject.eventAnnotationDelegate = self;
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
    [self refreshEventsArray];
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

- (void)refreshEventsArray {
    [self.dataHandlingObject getEventsFromDatabase];
}

- (void)populateMapWithEventswithFilter:(BOOL)filterValue{
    if (self.photoMap.annotations.count != 0){
        [self.photoMap removeAnnotations: self.photoMap.annotations];
    }
    
    if (self.eventsArray.count > 0 && !self.filtersWereSet)
    {
        for (Event *thisEvent in self.eventsArray)
        {
            MKPointAnnotation *eventAnnotationPoint = [[MKPointAnnotation alloc] init];
            eventAnnotationPoint.coordinate = thisEvent.eventCoordinates;
            eventAnnotationPoint.title = thisEvent.eventName;
            [self.photoMap addAnnotation:eventAnnotationPoint];
        }
    }
    
    else if (self.filteredEventsArray > 0 && self.filtersWereSet){
        NSLog(@"Filtered events array is populated since filters were applied");
        for (Event *thisEvent in self.filteredEventsArray)
        {
            MKPointAnnotation *eventAnnotationPoint = [[MKPointAnnotation alloc] init];
            eventAnnotationPoint.coordinate = thisEvent.eventCoordinates;
            eventAnnotationPoint.title = thisEvent.eventName;
            [self.photoMap addAnnotation:eventAnnotationPoint];
        }
    }
}

- (void)presentEventDetailsView: (Event *)eventToPresent {
    
    UIStoryboard *detailsSB = [UIStoryboard storyboardWithName:@"EventDetails" bundle:nil];
    EventDetailsViewController *detailedEventVC = (EventDetailsViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"DetailedEventView"];
    detailedEventVC.event = eventToPresent;
    MusicQueueViewController *musicQueueVC = (MusicQueueViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"MusicQueueView"];
    EventGalleryViewController *eventGalleryVC = (EventGalleryViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"EventGalleryView"];
    UITabBarController *eventSelectedTabBarController = (UITabBarController *)[detailsSB instantiateViewControllerWithIdentifier:@"DetailsTabBarController"];
    [eventSelectedTabBarController.tabBar setBackgroundColor:UIColorFromRGB(0x21ce99)];
    eventSelectedTabBarController.tabBar.translucent = YES;
    eventSelectedTabBarController.selectedIndex = 1;
    eventSelectedTabBarController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    eventSelectedTabBarController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    eventSelectedTabBarController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    eventSelectedTabBarController.viewControllers = @[musicQueueVC,detailedEventVC,eventGalleryVC];
    [self presentViewController:eventSelectedTabBarController animated:YES completion:nil];
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
    //self.filtersWereSet = YES;
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

- (void)refreshEventsDelegateMethod:(nonnull NSArray *)events {
    self.eventsArray = [NSMutableArray arrayWithArray:events];
    [self populateMapWithEventswithFilter:self.filtersWereSet];
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
    EventAnnotation *newEventAnnotationView = (EventAnnotation*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (newEventAnnotationView == nil) {
        newEventAnnotationView = [[EventAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        UIImage *resizedEventImage = [self resizeImage:[UIImage imageNamed:@"eventImage"] withSize:CGSizeMake(30.0, 30.0)];
        newEventAnnotationView.image = resizedEventImage;
        newEventAnnotationView.canShowCallout = NO;
    }
    return newEventAnnotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:YES];
    [self.dataHandlingObject getInfoForEventAnnotionWithTitle:view.annotation.title withCoordinates:view.annotation.coordinate];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *crnLoc = [locations lastObject];
    //NSString *mylatitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    //NSString *myLongitude = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
}

- (void)applyFiltersButtonWasPressed {
    NSLog(@"Applying Filters...");
    [self filterAnnotations];
}

- (void)resetFiltersButtonWasPressed {
    NSLog(@"Resetting Filters...");
    self.filtersWereSet = NO;
    [self.vibesCell resetVibes];
    [self.distanceCell resetDistance];
    [self.numberOfPeopleCell resetNumberOfPeople];
    [self.ageCell resetAgeRestrictions];

    
    ///upon resetting filters, empty the filtered events array
    //remove all the annotations on map and
    //add the events in the events array 
    
}

- (void) filterAnnotations {
    int ageRestriction = [self.ageCell getAgeRestrictions];
    NSMutableSet *vibesSet = [self.vibesCell getSelectedVibes];
    int distance = [self.distanceCell getDistance];
    int minNumPeople = [self.numberOfPeopleCell getMinNumPeople];
    int maxNumPeople = [self.numberOfPeopleCell getMaxNumPeople];

    //create an NSMutable filteredEvents property
    //iterate through local events array; if that event doesn't match these parameters
    //then don't add them to the filtered array
    
    //now iterate through the current annotations on map and remove them all
    //then just add the annotations that are in the filtered events array
}
- (void)refreshAfterEventCreation {
    [self refreshEventsArray];
}

- (void)eventDataForDetailedView:(nonnull NSDictionary *)eventData {
    self.eventToLoad = [[Event alloc] initWithDictionary:eventData];
    [self presentEventDetailsView:self.eventToLoad];
}

@end
