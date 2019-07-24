//
//  DataHandling.m
//  Pitch
//
//  Created by sbernal0115 on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DataHandling.h"
#import "Event.h"
#import "User.h"

//constants for database access to nodes and their children
static NSString * const DATABASE_USER_NODE = @"Users";
static NSString * const DATABASE_EVENT_NODE = @"Events";
//constants for event creation that correspond to fields in database
static NSString * const EVENT_NAME_KEY = @"Event Name";
static NSString * const EVENT_CREATOR_KEY = @"Created By";
static NSString * const EVENT_HAS_MUSIC_KEY = @"Has Music";
static NSString * const EVENT_IMAGE_URL_KEY = @"ImageURL";
static NSString * const EVENT_AGE_RESTRICTION_KEY = @"Age Restriction";
static NSString * const EVENT_ATTENDANCE_KEY = @"Attendance";
static NSString * const EVENT_LOCATION_KEY = @"Location";
static NSString * const EVENT_DESCRIPTION_KEY = @"Description";
//constants for user addition to database
static NSString * const USER_FIRSTNAME_KEY = @"First Name";
static NSString * const USER_LASTNAME_KEY = @"Last Name";
static NSString * const USER_EMAIL_KEY = @"Email";
static NSString * const USER_PROFILE_IMAGE_KEY = @"Profile Image";
static NSString * const USER_SCREEN_NAME_KEY = @"Screen Name";
static NSString * const USER_BACKGROUND_KEY = @"BackgroundImageURL";

@interface DataHandling()
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;

@end

@implementation DataHandling

+ (instancetype)shared {
    static DataHandling *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    self.databaseUsersReference = [[[FIRDatabase database] reference] child:DATABASE_USER_NODE];
    self.databaseEventsReference = [[[FIRDatabase database] reference] child:DATABASE_EVENT_NODE];
    
    return self;
}

- (void) getEventsArray {
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    
    [self.databaseEventsReference
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot *snapshot) {
         // Loop over children, all of which are dictionaries with event info
         NSEnumerator *children = [snapshot children];
         FIRDataSnapshot *child;
         while (child = [children nextObject]) {
             Event *eventToAdd = [[Event alloc] initWithDictionary:child.value];
             [eventsArray addObject:eventToAdd];
         }
         [self.delegate updateEvents:eventsArray];
     }];
}


- (void)addEventToDatabase:(Event *)definedEvent{
    NSString *newEventID = [[NSUUID UUID] UUIDString]; // Generate a UUID
    NSString *newEventName = definedEvent.eventName;
    NSString *newEventCreator = @"Sebastian";
    NSString *newEventHasMusic = definedEvent.eventHasMusic;
    NSString *newEventAttendanceCount = [NSString stringWithFormat:@"%d", definedEvent.eventAttendanceCount];
    NSString *newEventImageURLString = definedEvent.eventImageURLString;
    NSString *newEventAgeRestriction = [NSString stringWithFormat:@"%d", definedEvent.eventAgeRestriction];
    NSString *newEventDescription = definedEvent.eventDescription;
    NSString *newEventLocation = definedEvent.eventLocationString;
    NSDictionary *eventInfo = @{
                                EVENT_NAME_KEY: newEventName,
                                EVENT_CREATOR_KEY: newEventCreator,
                                EVENT_HAS_MUSIC_KEY: newEventHasMusic,
                                EVENT_ATTENDANCE_KEY: newEventAttendanceCount,
                                EVENT_IMAGE_URL_KEY: newEventImageURLString,
                                EVENT_AGE_RESTRICTION_KEY: newEventAgeRestriction,
                                EVENT_LOCATION_KEY: newEventLocation,
                                EVENT_DESCRIPTION_KEY: newEventDescription
                                };
    [[self.databaseEventsReference child:newEventID] setValue: eventInfo];
}

//here take in as a string what aspect of the user's
//profile is being changed to easily configure it in the database as well
- (void)setUserDetails:(NSString *) specificFieldKey
{
}


- (void)addUserToDatabase:(FIRUser *)authFirebaseUser withUserName:(NSString *)userName{
    NSString *userID = authFirebaseUser.uid;
    NSString *fullName = authFirebaseUser.displayName;
    NSArray *nameArray = [fullName componentsSeparatedByString:@" "];
    NSString *profileImageURLString = [authFirebaseUser.photoURL absoluteString];
    NSDictionary *userInfo = @{ USER_FIRSTNAME_KEY: [nameArray objectAtIndex:0],
                                USER_LASTNAME_KEY: [nameArray  objectAtIndex:1],
                                USER_PROFILE_IMAGE_KEY : profileImageURLString,
                                USER_EMAIL_KEY: authFirebaseUser.email,
                                USER_PROFILE_IMAGE_KEY: profileImageURLString,
                                USER_SCREEN_NAME_KEY: userName,
                                USER_BACKGROUND_KEY: @"some background image"
                                };
    [[self.databaseUsersReference child:userID] setValue: userInfo];
}


@end
