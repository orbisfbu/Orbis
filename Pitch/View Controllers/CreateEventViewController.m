//
//  CreateEventViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
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

@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
@property (strong, nonatomic) UITableView *createEventTV;
@property (strong, nonatomic) NSMutableArray *customPollCellsArray;
@property (strong, nonatomic) User *makingUser;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.databaseEventsReference = [[[FIRDatabase database] reference] child:DATABASE_EVENTS_NODE];
    self.databaseUsersReference = [[[FIRDatabase database] reference] child:DATABASE_USERS_NODE];
    Event *newEvent = [[Event alloc] init];
    newEvent.eventNameString = @"Another Festival";
    newEvent.gatheringTypeString = @"Classical";
    newEvent.eventOwnerUser = self.makingUser;
    NSString *userID = @"MVUXlDMufZhpqOmFuSdsUJfw2sR2";
    [[self.databaseUsersReference child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        User *newUser = [[User alloc] initWithDictionary:snapshot.value];
        [self addEventToDatabase:newEvent withCreator:newUser];
} withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"test failed!");
    }];
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    self.createEventTV = [[UITableView alloc] initWithFrame:frame];
    self.createEventTV.layer.cornerRadius = 10;
    [self.view addSubview:self.createEventTV];
    [self.createEventTV setFrame:frame];
    self.createEventTV.delegate = self;
    self.createEventTV.dataSource = self;
    [self.createEventTV registerNib:[UINib nibWithNibName:@"EventTitleCell" bundle:nil] forCellReuseIdentifier:@"EventTitleCell"];
    [self.createEventTV registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.createEventTV registerNib:[UINib nibWithNibName:@"LocationCell" bundle:nil] forCellReuseIdentifier:@"LocationCell"];
    [self.createEventTV registerNib:[UINib nibWithNibName:@"PollsTitleCell" bundle:nil] forCellReuseIdentifier:@"PollsTitleCell"];
    [self.createEventTV registerNib:[UINib nibWithNibName:@"CustomPollCell" bundle:nil] forCellReuseIdentifier:@"CustomPollCell"];
    [self.createEventTV setAllowsSelection:NO];
}

- (void)addEventToDatabase:(Event *)currentEvent withCreator:(User *)currentUser{
    NSString *eventID = [[NSUUID UUID] UUIDString]; // Generate a UUID
    NSString *eventName = currentEvent.eventNameString;
    NSString *gatheringTypeName = currentEvent.gatheringTypeString;
    NSString *eventOwner = currentUser.userNameString;
//    NSString *eventImageURLString = currentEvent.eventImageURLString;
    NSDictionary *eventInfo = @{
                               NAME_OF_EVENT: eventName,
                               GATHERING_TYPE_NAME: gatheringTypeName,
//                               EVENT_IMAGE_URLSTRING : eventImageURLString,
                               EVENT_OWNER: eventOwner
                               };
    [[self.databaseEventsReference child:eventID] setValue: eventInfo];
    NSLog(SUCCESSFUL_EVENT_SAVE);
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell;
    //[cell awakeFromNib];
    if (indexPath.row == 0) {
        cell = [self.createEventTV dequeueReusableCellWithIdentifier:@"EventTitleCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 1) {
        cell = [self.createEventTV dequeueReusableCellWithIdentifier:@"VibesCell"];
        [cell awakeFromNib];
    } else if (indexPath.row == 2) {
        cell = [self.createEventTV dequeueReusableCellWithIdentifier:@"LocationCell"];
    } else if (indexPath.row == 3) {
        cell = [self.createEventTV dequeueReusableCellWithIdentifier:@"PollsTitleCell"];
    } else {
        cell = [self.createEventTV dequeueReusableCellWithIdentifier:@"CustomPollCell"];
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
