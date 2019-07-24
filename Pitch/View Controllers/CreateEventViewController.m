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
#import "VibesCell.h"
#import "EventTitleCell.h"
#import "LocationCell.h"
#import "PollsTitleCell.h"
#import "CustomPollCell.h"

@import UIKit;
@import Firebase;
@import FirebaseAuth;

//Fields to be used when saving event to database
static NSString * const NAME_OF_EVENT = @"Name of Event";
static NSString * const GATHERING_TYPE_NAME = @"Gathering Type";
static NSString * const EVENT_OWNER = @"Creator of the Event";
static NSString * const EVENT_IMAGE_URLSTRING = @"Event Image";
static NSString * const DATABASE_EVENTS_NODE = @"Events";
static NSString * const DATABASE_USERS_NODE = @"Users";


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

//this flag will be used to trigger initial loading
//if YES, then event is created
//if NO, then user is prompted to sign-in/signup, and those views will be displayed
@property (nonatomic) BOOL *userIsSignedIn;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCreateEventButton];
    self.createEventTableView.delegate = self;
    self.createEventTableView.dataSource = self;
    [self.createEventTableView setAllowsSelection:NO];
    self.databaseEventsReference = [[[FIRDatabase database] reference] child:DATABASE_EVENTS_NODE];
    self.databaseUsersReference = [[[FIRDatabase database] reference] child:DATABASE_USERS_NODE];
    
    CGRect frame = CGRectMake(self.createEventButton.frame.origin.x, self.createEventButton.frame.origin.y + self.createEventButton.frame.size.height, self.createEventButton.frame.size.width, self.view.frame.size.height - self.createEventButton.frame.size.height);
    self.createEventTableView = [[UITableView alloc] initWithFrame:frame];
    self.createEventTableView.layer.cornerRadius = 10;
    [self.view addSubview:self.createEventTableView];
    [self.createEventTableView setFrame:frame];
    self.createEventTableView.delegate = self;
    self.createEventTableView.dataSource = self;
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"EventTitleCell" bundle:nil] forCellReuseIdentifier:@"EventTitleCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"LocationCell" bundle:nil] forCellReuseIdentifier:@"LocationCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"PollsTitleCell" bundle:nil] forCellReuseIdentifier:@"PollsTitleCell"];
    [self.createEventTableView registerNib:[UINib nibWithNibName:@"CustomPollCell" bundle:nil] forCellReuseIdentifier:@"CustomPollCell"];
    [self.createEventTableView setAllowsSelection:NO];
    [self.view addSubview:self.createEventTableView];
    
    Event *newEvent = [[Event alloc] init];
    //    newEvent.eventNameString = @"Another Festival";
    //    newEvent.gatheringTypeString = @"Classical";
    //    newEvent.eventOwnerUser = self.makingUser;
    //    NSString *userID = @"MVUXlDMufZhpqOmFuSdsUJfw2sR2";
    //    [[self.databaseUsersReference child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //        User *newUser = [[User alloc] initWithDictionary:snapshot.value];
    //        [self addEventToDatabase:newEvent withCreator:newUser];
    //} withCancelBlock:^(NSError * _Nonnull error) {
    //        NSLog(@"test failed!");
    //    }];
    
}

- (void) makeCreateEventButton{
    // Add create event button
    self.createEventButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    [self.createEventButton setTitle:@"Create Event" forState:UIControlStateNormal];
    [self.createEventButton setBackgroundColor:[UIColor greenColor]];
    self.createEventButton.layer.cornerRadius = 5;
    self.createEventButton.alpha = 1;
    [self.createEventButton setEnabled:NO];
    [self.createEventButton addTarget:self action:@selector(createEventButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createEventButton];
}

- (void)addEventToDatabase:(Event *)currentEvent withCreator:(User *)currentUser{
    // Sebastian is changing this
    //    NSString *eventID = [[NSUUID UUID] UUIDString]; // Generate a UUID
    //    NSString *eventName = currentEvent.eventName;
    //    //NSString *gatheringTypeName = currentEvent.gatheringTypeString;
    //    NSString *eventOwner = currentUser.userNameString;
    ////    int numGuests = currentEvent.peopleAttendingCount;
    ////    NSString *numberOfGuests = [[NSString alloc] initWithFormat:@"%i", numGuests];
    ////    NSString *eventImageURLString = currentEvent.eventImageURLString;
    //    NSDictionary *eventInfo = @{
    //                               NAME_OF_EVENT: eventName,
    //                               GATHERING_TYPE_NAME: gatheringTypeName,
    ////                               EVENT_IMAGE_URLSTRING : eventImageURLString,
    ////                               NUMBER_OF_GUESTS : numberOfGuests,
    //                               EVENT_OWNER: eventOwner
    //                               };
    //    [[self.databaseEventsReference child:eventID] setValue: eventInfo];
    //    NSLog(SUCCESSFUL_EVENT_SAVE);
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell;
    //[cell awakeFromNib];
    
    if (indexPath.row == 0) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"EventTitleCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 1) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"VibesCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 2) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    } else if (indexPath.row == 3) {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"PollsTitleCell"];
    } else {
        cell = [self.createEventTableView dequeueReusableCellWithIdentifier:@"CustomPollCell"];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.customPollCellsArray.count + 4);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end

