//
//  CreateEventViewController.m
//  Pitch
//
//  Created by ezietz on 7/23/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "CreateEventViewController.h"
#import "UserViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FirebaseDatabase/FirebaseDatabase.h"
#import "AppDelegate.h"
#import "UserViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FBSDKLoginManagerLoginResult.h"
#import <FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Event.h"
#import "User.h"
#import "DataHandling.h"
#import "VibesCell.h"
#import "AgeCell.h"
#import "EventTitleCell.h"
#import "LocationCell.h"
#import "PollsTitleCell.h"
#import "CustomPollCell.h"
#import <MapKit/MKLocalSearchRequest.h>
#import <MapKit/MKLocalSearch.h>


@import UIKit;
@import Firebase;
@import FirebaseAuth;

//Fields to be used when saving event to database
static NSString * const NAME_OF_EVENT = @"Name of Event";
static NSString * const EVENT_OWNER = @"Creator of the Event";
static NSString * const EVENT_IMAGE_URLSTRING = @"Event Image";


//Debugging/Error Messages
static NSString * const SUCCESSFUL_EVENT_SAVE = @"Successfully saved Event info to database";


@interface CreateEventViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FBSDKLoginButton *FBLoginButton;
@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
@property (strong, nonatomic) NSMutableArray *customPollCellsArray;
@property (strong, nonatomic) User *makingUser;
@property (strong, nonatomic) UITableView *createEventTableView;
@property (strong, nonatomic) UIButton *createEventButton;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.createEventTableView.delegate = self;
    self.createEventTableView.dataSource = self;
    [self.createEventTableView setAllowsSelection:NO];
    [self makeCreateEventButton];
    CGRect frame = CGRectMake(self.createEventButton.frame.origin.x, self.createEventButton.frame.origin.y + self.createEventButton.frame.size.height, self.createEventButton.frame.size.width, self.view.frame.size.height - self.createEventButton.frame.size.height);
    self.createEventTableView = [[UITableView alloc] initWithFrame:frame];
    self.createEventTableView.layer.cornerRadius = 10;
    [self.view addSubview:self.createEventTableView];
    [self.createEventTableView setFrame:frame];
    self.createEventTableView.delegate = self;
    self.createEventTableView.dataSource = self;
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"EventTitleCell" bundle:nil] forCellReuseIdentifier:@"EventTitleCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"LocationCell" bundle:nil] forCellReuseIdentifier:@"LocationCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"AgeCell" bundle:nil] forCellReuseIdentifier:@"AgeCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"EventPictureCell" bundle:nil] forCellReuseIdentifier:@"EventPictureCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"PollsTitleCell" bundle:nil] forCellReuseIdentifier:@"PollsTitleCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"CustomPollCell" bundle:nil] forCellReuseIdentifier:@"CustomPollCell"];
    [self.createEventTableView setAllowsSelection:NO];
    [self.view addSubview:self.createEventTableView];
}


- (void) createEventButtonPressed
{
    NSDictionary *eventDefinition = @{
                                      @"Created By": @"Sebastian Bernal",
                                      @"Event Name": @"Testing with integers",
                                      @"Has Music": @"YES",
                                      @"Attendance": @56,
                                      @"ImageURL": @"https://bit.ly/2SYp8Za",
                                      @"Description": @"Another cool description",
                                      @"Age Restriction": @69,
                                      @"Location": @"37.777937 -122.415954",
                                      @"Vibes": @[@"Vibe1",@"Vibe2",@"Vibe3"],
                                      @"MinPeople":@"1",
                                      @"MaxPeople":@"500"
                                      };
    Event *eventToAdd = [[Event alloc] initWithDictionary:eventDefinition];
    [[DataHandling shared] addEventToDatabase:eventToAdd];
    [self.delegate refreshAfterEventCreation];
}


- (void) makeCreateEventButton{
    self.createEventButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    [self.createEventButton setTitle:@"Create Event" forState:UIControlStateNormal];
    [self.createEventButton setBackgroundColor:[UIColor clearColor]];
    self.createEventButton.layer.borderWidth = 1.0f;
    self.createEventButton.layer.borderColor = [UIColor greenColor].CGColor;
    [self.createEventButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.createEventButton.layer.cornerRadius = 5;
    self.createEventButton.alpha = 1;
    [self.createEventButton setEnabled:YES];
    [self.createEventButton addTarget:self action:@selector(createEventButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createEventButton];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell;
    //[cell awakeFromNib];
    if (indexPath.row == 0) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"EventTitleCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 1) {
//        [self.createEventTableView beginUpdates];
//        [self.createEventTableView endUpdates];
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"LocationCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 2) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"VibesCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 3) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"AgeCell"];
    } else if (indexPath.row == 4) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"EventPictureCell"];
    } else if (indexPath.row == 5) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"PollsTitleCell"];
    } else {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"CustomPollCell"];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    int arrayCount = (int)self.customPollCellsArray.count;
//    NSLog(@"value : %lu %d", (unsigned long)self.customPollCellsArray.count, arrayCount);
    return (self.customPollCellsArray.count + 6);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([indexPath row] == 1) {
//        return 300;
//    }
//    return UITableViewAutomaticDimension;
//}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Deselect cell
//    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
//
//    // Toggle 'selected' state
//    BOOL isSelected = ![self cellIsSelected:indexPath];
//
//    // Store cell 'selected' state keyed on indexPath
//    NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
//    [selectedIndexes setObject:1 forKey:indexPath];
//
//    [self.createEventTableView beginUpdates];
//    [self.createEventTableView endUpdates];
//}
//-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    if ([indexPath row] == 1) {
//    [self.createEventTableView beginUpdates];
//        [self.createEventTableView endUpdates]; }
//}

@end
