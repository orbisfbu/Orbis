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

@import UIKit;
@import Firebase;
@import FirebaseAuth;

//Fields to be used when saving event to database
static NSString * const NAME_OF_EVENT = @"Name of Event";
static NSString * const GATHERING_TYPE_NAME = @"Gathering Type";
static NSString * const EVENT_OWNER = @"Creator of the Event";
static NSString * const EVENT_IMAGE_URLSTRING = @"Event Image";
static NSString * const NUMBER_OF_GUESTS = @"Number of Guests";
static NSString * const IS_MUSIC_ALLOWED = @"Music Allowed";
static NSString * const DATABASE_EVENTS_NODE = @"Events";
static NSString * const DATABASE_USERS_NODE = @"Users";


//Debugging/Error Messages
static NSString * const SUCCESSFUL_EVENT_SAVE = @"Successfully saved Event info to database";

@interface CreateEventViewController ()

@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
@property (strong, nonatomic) User *makingUser; // added

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
//    newEvent.peopleAttendingCount = 25;
    NSString *userID = @"MVUXlDMufZhpqOmFuSdsUJfw2sR2";
//    NSString *userID = [FIRAuth auth].currentUser.uid;
    // define makingUser as the current authenticated user
    [[self.databaseUsersReference child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        User *newUser = [[User alloc] initWithDictionary:snapshot.value];
        [self addEventToDatabase:newEvent withCreator:newUser];
        NSLog([NSString stringWithFormat:@"**************%@", newUser.profileImageURLString]);
} withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"test failed!");
    }];
    
    
    
}

- (void)addEventToDatabase:(Event *)currentEvent withCreator:(User *)currentUser{
//    NSString *eventID = [[NSUUID UUID] UUIDString]; // Generate a UUID
//    NSString *eventName = currentEvent.eventNameString;
//    NSString *gatheringTypeName = currentEvent.gatheringTypeString;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
