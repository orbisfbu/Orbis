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
#import "EventDetailsViewController.h"
#import "CreateEventViewController.h"
#import "MusicQueueViewController.h"
#import "EventGalleryViewController.h"
#import "ApplyFiltersCell.h"
#import "DragCell.h"
#import "EventAnnotation.h"
#import "CreateEventViewController.h"
#import "MusicQueueViewController.h"
#import "UIImageView+AFNetworking.h"
#import "EventGalleryViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ExploreViewController () <UITableViewDelegate, UITableViewDataSource, GetEventsArrayDelegate, GetFilteredEventsArrayDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, AddEventToMapDelegate, ApplyFiltersDelegate>

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
@property (strong, nonatomic) UIButton *refreshMapButton;
@property BOOL isScrollingTVUp;
@property BOOL filtersWereSet;
@property BOOL searchWasMade;

@end

@implementation ExploreViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.filtersWereSet = NO;
    self.searchBarOutlet.delegate = self;
    self.dataHandlingObject = [DataHandling shared];
    self.dataHandlingObject.delegate = self;
    self.dataHandlingObject.filteredEventsDelegate = self;
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
    [self createRefreshButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager startUpdatingLocation];
    //retrieve events from database
    [self refreshEventsArray];
}

- (void)createRefreshButton{
    self.refreshMapButton = [[UIButton alloc] initWithFrame:CGRectMake(self.searchBar.frame.origin.x + self.searchBar.frame.size.width * .9, self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 5, self.searchBar.frame.size.height/2.5, self.searchBar.frame.size.height/2.5)];
    self.refreshMapButton.alpha = 1;
    [self.refreshMapButton setEnabled:YES];
    [self.refreshMapButton addTarget:self action:@selector(refreshEventsArray) forControlEvents:UIControlEventTouchUpInside];
    UIImage *resizedRefreshIcon = [self resizeImage:[UIImage imageNamed:@"refreshIcon"] withSize:CGSizeMake(self.searchBar.frame.size.height/2, self.searchBar.frame.size.height/2)];
    [self.refreshMapButton setImage:resizedRefreshIcon forState:UIControlStateNormal];
    [self.view insertSubview:self.refreshMapButton belowSubview:self.dropDownFilterTV];
}

- (void)refreshEventsArray {
    [self.dataHandlingObject getEventsFromDatabase];
}

- (BOOL) isFutureEvent:(Event *) eventToCheck {
    BOOL returnValue = nil;
    NSDate *currentDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    NSDate *formattedCurrentDate = [dateFormatter dateFromString:currentDateString];
    NSDate *startDate = [dateFormatter dateFromString:eventToCheck.startDateString];
    NSComparisonResult comparisonResult = [formattedCurrentDate compare:startDate];
    if (comparisonResult == NSOrderedAscending || comparisonResult == NSOrderedSame) { //The current Date is earlier in time than start Date
        returnValue = YES;
    }
    else if (comparisonResult == NSOrderedDescending) { // The receiver is later in time than start Date
            returnValue = NO;
    }
    return returnValue;
}

- (void)populateMapWithEventswithFilter:(BOOL)filterValue withSearchValue:(BOOL) didSearch { // Populating map with future events only
    if (self.photoMap.annotations.count != 0){
        [self.photoMap removeAnnotations: self.photoMap.annotations];
    }
    if (self.eventsArray.count > 0 && !self.filtersWereSet)
    {
        for (Event *thisEvent in self.eventsArray)
        {
            if ([self isFutureEvent:(thisEvent)]) {
                
                if (didSearch && [[thisEvent.eventName lowercaseString] containsString:[NSString stringWithFormat:@"%@", [self.searchBarOutlet.text lowercaseString]]]) {
                    // populate map with future event that contains search text/substring of search text
                    EventAnnotation *eventAnnotationPoint = [[EventAnnotation alloc] init];
                    eventAnnotationPoint.coordinate = thisEvent.eventCoordinates;
                    eventAnnotationPoint.title = thisEvent.ID;
                    eventAnnotationPoint.mainImageURLString = thisEvent.eventImageURLString;
                    eventAnnotationPoint.startDateString = thisEvent.startDateString;
                    [self.photoMap addAnnotation:eventAnnotationPoint];
                }
                else if (!didSearch) {
                    EventAnnotation *eventAnnotationPoint = [[EventAnnotation alloc] init];
                    eventAnnotationPoint.coordinate = thisEvent.eventCoordinates;
                    eventAnnotationPoint.title = thisEvent.ID;
                    eventAnnotationPoint.mainImageURLString = thisEvent.eventImageURLString;
                    eventAnnotationPoint.startDateString = thisEvent.startDateString;
                    [self.photoMap addAnnotation:eventAnnotationPoint];
                }
            }
        }
    }
    else if (self.filteredEventsArray > 0 && self.filtersWereSet){
        for (Event *thisEvent in self.filteredEventsArray)
        {
            if ([self isFutureEvent:(thisEvent)]) {
                if (didSearch && [[thisEvent.eventName lowercaseString] containsString:[NSString stringWithFormat:@"%@", [self.searchBarOutlet.text lowercaseString]]]) {
                    // populate map with future event that contains search text/substring of search text
                    EventAnnotation *eventAnnotationPoint = [[EventAnnotation alloc] init];
                    eventAnnotationPoint.coordinate = thisEvent.eventCoordinates;
                    eventAnnotationPoint.title = thisEvent.ID;
                    eventAnnotationPoint.mainImageURLString = thisEvent.eventImageURLString;
                    eventAnnotationPoint.startDateString = thisEvent.startDateString;
                    [self.photoMap addAnnotation:eventAnnotationPoint];
                }
                else if (!didSearch) {
                    EventAnnotation *eventAnnotationPoint = [[EventAnnotation alloc] init];
                    eventAnnotationPoint.coordinate = thisEvent.eventCoordinates;
                    eventAnnotationPoint.title = thisEvent.ID;
                    eventAnnotationPoint.mainImageURLString = thisEvent.eventImageURLString;
                    eventAnnotationPoint.startDateString = thisEvent.startDateString;
                    [self.photoMap addAnnotation:eventAnnotationPoint];
                }
            }
        }
    }
}

- (void)presentEventDetailsView: (Event *)eventToPresent {
    UIStoryboard *detailsSB = [UIStoryboard storyboardWithName:@"EventDetails" bundle:nil];
    EventDetailsViewController *detailedEventVC = (EventDetailsViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"DetailedEventView"];
    detailedEventVC.event = eventToPresent;
    
    MusicQueueViewController *musicQueueVC = (MusicQueueViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"MusicQueueView"];
    musicQueueVC.event = eventToPresent;
    EventGalleryViewController *eventGalleryVC = (EventGalleryViewController *)[detailsSB instantiateViewControllerWithIdentifier:@"EventGalleryView"];
    eventGalleryVC.event = eventToPresent;
    UITabBarController *eventSelectedTabBarController = (UITabBarController *)[detailsSB instantiateViewControllerWithIdentifier:@"DetailsTabBarController"];
    [eventSelectedTabBarController.tabBar setBackgroundColor:UIColorFromRGB(0x21ce99)];
    eventSelectedTabBarController.tabBar.translucent = YES;
    eventSelectedTabBarController.selectedIndex = 1;
    eventSelectedTabBarController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    eventSelectedTabBarController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    eventSelectedTabBarController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    eventSelectedTabBarController.viewControllers = @[musicQueueVC,detailedEventVC,eventGalleryVC];
    [[eventSelectedTabBarController tabBar] setTintColor:(UIColorFromRGB(0x0d523d))];
    [[eventSelectedTabBarController tabBar] setBackgroundColor:(UIColorFromRGB(0xf5f5f5))];
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
    [self populateMapWithEventswithFilter:self.filtersWereSet withSearchValue:self.searchWasMade];
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
    NSString *annotationIdentifier = [NSString stringWithFormat:@"%@", annotation.title];
    MKAnnotationView *newEventAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    else if ([annotation isKindOfClass:[EventAnnotation class]]){
        EventAnnotation *thisAnnotation = (EventAnnotation *)annotation;
        NSURL *url = [NSURL URLWithString:thisAnnotation.mainImageURLString];
        UIImageView *eventImageView = [[UIImageView alloc] init];
        [eventImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"eventImage"]];
//        [eventImageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:url] placeholderImage:[UIImage imageNamed:@"eventImage"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//            UIImage *resizedEventImage = [self resizeImage:image withSize:CGSizeMake(30.0, 30.0)];
//            newEventAnnotationView.image = resizedEventImage;
//        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//            //
//        }];
        UIImage *resizedEventImage = [self resizeImage:eventImageView.image withSize:CGSizeMake(30.0, 30.0)];
        newEventAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:thisAnnotation reuseIdentifier:annotationIdentifier];
        newEventAnnotationView.image = resizedEventImage;
        newEventAnnotationView.layer.masksToBounds = true;
        newEventAnnotationView.layer.cornerRadius = newEventAnnotationView.frame.size.height/2;
        newEventAnnotationView.canShowCallout = NO;
    }
    
    return newEventAnnotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    if([annotationView.annotation isKindOfClass:[MKUserLocation class]]){
        return;
    }
    [mapView deselectAnnotation:annotationView.annotation animated:YES];
    [self.dataHandlingObject getEvent:annotationView.annotation.title withCompletion:^(Event * _Nonnull event) {
        [self presentEventDetailsView:event];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Error getting location"
                                                                   message:[NSString stringWithFormat:@"Error %@", error]
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                     }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"Error: %@",error.description);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [DataHandling shared].userLocation = [locations lastObject];
}

- (void)applyFiltersButtonDelegate {
    NSLog(@"Applying Filters...");
    self.filtersWereSet = YES;
    [self filterAnnotations];
}

- (void)resetFiltersButtonDelegate {
    NSLog(@"Resetting Filters...");
    self.filtersWereSet = NO;
    [self.vibesCell resetVibes];
    [self.distanceCell resetDistance];
    [self.numberOfPeopleCell resetNumberOfPeople];
    [self.ageCell resetAgeRestrictions];
    [self refreshEventsArray];
}

- (void) filterAnnotations {
    int ageRestriction = [self.ageCell getAgeRestrictions];
    NSMutableSet *vibesSet = [self.vibesCell getSelectedVibes];
    long distance = [self.distanceCell getDistance];
    
    long minNumPeople = [self.numberOfPeopleCell getMinNumPeople];
    long maxNumPeople = [self.numberOfPeopleCell getMaxNumPeople];
    NSDictionary *filterValues = @{
                                  @"Age Restriction": @(ageRestriction),
                                  @"Distance": @(distance),
                                  @"Min People": @(minNumPeople),
                                  @"Max People": @(maxNumPeople),
                                  @"Vibes": vibesSet
                                  };
    [self.dataHandlingObject getFilteredEventsFromDatabase:filterValues userLocation:[DataHandling shared].userLocation];
}

- (void)refreshAfterEventCreation {
    [self refreshEventsArray];
}

- (void)refreshFilteredEventsDelegateMethod:(nonnull NSArray *)filteredEvents {
    if (filteredEvents.count == 0){
        [self.applyFiltersCell applyFiltersButtonPressed:NO];
        [self presentAlert:@"No events found with these filters" withMessage:@"Try changing your search criteria"];
    }
    else{
        self.filteredEventsArray = [NSMutableArray arrayWithArray:filteredEvents];
        [self populateMapWithEventswithFilter:self.filtersWereSet withSearchValue:self.searchWasMade];
        [self removeFilterMenu];
        self.filterMenuIsShowing = NO;
    }
}

- (void)presentAlert:(NSString *)alertTitle withMessage:(NSString *)alertMessage
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         // handle response here.
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([self.searchBarOutlet.text isEqualToString:@""]) {
        self.searchWasMade = NO;
        [self refreshEventsArray]; // map is populated with all future events
    }
    else {
        self.searchWasMade = YES;
        [self refreshEventsArray]; // map is populated with future events that fit search criteria
    }
    [self.searchBarOutlet resignFirstResponder];
}

@end
