//
//  DataHandling.m
//  Pitch
//
//  Created by sbernal0115 on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DataHandling.h"



//constants for database access to nodes and their children
static NSString * const DATABASE_USERS_COLLECTION = @"users";
static NSString * const DATABASE_EVENTS_COLLECTION = @"events";
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
@property (nonatomic, readwrite) FIRFirestore *database;
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
    self.database = [FIRFirestore firestore];
    return self;
}

- (void)getEventsArray {
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting events from database: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 Event *eventToAdd = [[Event alloc] initWithDictionary:document.data];
                 NSLog(@"THIS IS AN ATTEMPT, %@", document.data[@"polls"][@"poll1"][@"OptionName1"]);
                 [eventsArray addObject:eventToAdd];
             }
         }
         [self.delegate updateEvents:eventsArray];
     }];
}

- (void)addEventToDatabase:(Event *)definedEvent{
    //here you can use the current user class to just set the eventCreator name
    NSString *newEventCreator = @"Sebastian";
    NSString *newEventHasMusic = definedEvent.eventHasMusic;
    NSString *newEventAttendanceCount = [NSString stringWithFormat:@"%d", definedEvent.eventAttendanceCount];
    NSString *newEventImageURLString = definedEvent.eventImageURLString;
    NSString *newEventAgeRestriction = [NSString stringWithFormat:@"%d", definedEvent.eventAgeRestriction];
    NSString *newEventDescription = definedEvent.eventDescription;
    NSString *newEventLocation = definedEvent.eventLocationString;
    NSString *newEventName = definedEvent.eventName;
    NSDictionary *eventInfo = @{
                                EVENT_CREATOR_KEY: newEventCreator,
                                EVENT_HAS_MUSIC_KEY: newEventHasMusic,
                                EVENT_ATTENDANCE_KEY: newEventAttendanceCount,
                                EVENT_IMAGE_URL_KEY: newEventImageURLString,
                                EVENT_AGE_RESTRICTION_KEY: newEventAgeRestriction,
                                EVENT_LOCATION_KEY: newEventLocation,
                                EVENT_DESCRIPTION_KEY: newEventDescription,
                                EVENT_NAME_KEY:newEventName
                                };
    [[[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] documentWithPath:newEventName] setData:eventInfo
         completion:^(NSError * _Nullable error) {
       if (error != nil) {
           NSLog(@"Error adding event: %@", error);
       } else {
           NSLog(@"CREATED LATEST EVENT");
       }
   }];
}

- (void)addUserToDatabase:(User *)thisUser withUserID:(NSString *)createdUserID{
    NSString *fullName = thisUser.userNameString;
    NSArray *nameArray = [fullName componentsSeparatedByString:@" "];
    NSString *profileImageURLString = thisUser.profileImageURLString;
    NSMutableDictionary *userInfoDict = [NSMutableDictionary new];
    if ([nameArray objectAtIndex:0]) {
        [userInfoDict setObject:[nameArray objectAtIndex:0] forKey:USER_FIRSTNAME_KEY];
    }
    if ([nameArray objectAtIndex:1]) {
        [userInfoDict setObject:[nameArray objectAtIndex:1] forKey:USER_LASTNAME_KEY];
    }
    NSDictionary *userInfo = @{ USER_FIRSTNAME_KEY: [nameArray objectAtIndex:0],
                                USER_LASTNAME_KEY: [nameArray  objectAtIndex:1],
                                USER_PROFILE_IMAGE_KEY : profileImageURLString,
                                USER_EMAIL_KEY: thisUser.email,
                                USER_PROFILE_IMAGE_KEY: profileImageURLString,
                                USER_SCREEN_NAME_KEY: thisUser.screenNameString,
                                USER_BACKGROUND_KEY: thisUser.profileBackgroundImageURLString
                                };
    [[[self.database collectionWithPath:DATABASE_USERS_COLLECTION] documentWithPath:createdUserID] setData:userInfo
      completion:^(NSError * _Nullable error) {
          if (error != nil) {
              NSLog(@"Error adding user: %@", error);
          } else {
              NSLog(@"CREATED LATEST USER");
          }
      }];
}


- (void)loadUserInfoAndApp: (NSString *)userID{
{
    [[[self.database collectionWithPath:@"users"] documentWithPath:userID] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot.exists)
        {
            [[UserInSession shared] setCurrentUser:snapshot.data];
            [self.sharedUserDelegate segueToAppUponLogin];
        }
        else{
            NSLog(@"THIS USER DOESNT EXIST");
            }
        }];
    
    }
}

@end
