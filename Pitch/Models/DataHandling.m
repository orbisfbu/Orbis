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
static NSString * const EVENT_VIBES_KEY = @"Vibes";
static NSString * const EVENT_MINPEOPLE_KEY = @"MinPeople";
static NSString * const EVENT_MAXPEOPLE_KEY = @"MaxPeople";
//constants for user addition to database
static NSString * const USER_FIRSTNAME_KEY = @"First Name";
static NSString * const USER_LASTNAME_KEY = @"Last Name";
static NSString * const USER_EMAIL_KEY = @"Email";
static NSString * const USER_PROFILE_IMAGE_KEY = @"ProfileImageURL";
static NSString * const USERNAME_KEY = @"Username";
static NSString * const USER_BACKGROUND_KEY = @"BackgroundImageURL";
//set this text to some default text or something like "change bio now!"
static NSString * const USER_BIO_KEY = @"Bio";

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

- (void)getEventsFromDatabase {
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting events from database: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 Event *eventToAdd = [[Event alloc] initWithDictionary:document.data];
                 [eventsArray addObject:eventToAdd];
             }
         }
         [self.delegate refreshEventsDelegateMethod:eventsArray];
     }];
}

- (void)addEventToDatabase:(Event *)definedEvent{
    NSDictionary *eventInfo = @{
                                EVENT_CREATOR_KEY: [UserInSession shared].sharedUser.nameString,
                                EVENT_HAS_MUSIC_KEY: definedEvent.eventHasMusic,
                                EVENT_ATTENDANCE_KEY: @(definedEvent.eventAttendanceCount),
                                EVENT_IMAGE_URL_KEY: definedEvent.eventImageURLString,
                                EVENT_AGE_RESTRICTION_KEY: @(definedEvent.eventAgeRestriction),
                                EVENT_MINPEOPLE_KEY: [NSString stringWithFormat:@"%d", definedEvent.minNumPeople],
                                EVENT_MAXPEOPLE_KEY: [NSString stringWithFormat:@"%d", definedEvent.maxNumPeople],
                                EVENT_LOCATION_KEY: definedEvent.eventLocationString,
                                EVENT_DESCRIPTION_KEY: definedEvent.eventDescription,
                                EVENT_NAME_KEY: definedEvent.eventName,
                                EVENT_VIBES_KEY: definedEvent.eventVibesArray
                                };
    [[[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] documentWithAutoID] setData:eventInfo
         completion:^(NSError * _Nullable error) {
       if (error != nil) {
           NSLog(@"Error adding event: %@", error);
       } else {
           NSLog(@"CREATED LATEST EVENT");
       }
   }];
}

- (void)addUserToDatabase:(User *)thisUser withUserID:(NSString *)createdUserID{
    NSString *fullName = thisUser.nameString;
    NSArray *nameArray = [fullName componentsSeparatedByString:@" "];
    NSMutableDictionary *userInfoDict = [NSMutableDictionary new];
    if ([nameArray objectAtIndex:0]) {
        [userInfoDict setObject:[nameArray objectAtIndex:0] forKey:USER_FIRSTNAME_KEY];
    }
    if ([nameArray objectAtIndex:1]) {
        [userInfoDict setObject:[nameArray objectAtIndex:1] forKey:USER_LASTNAME_KEY];
    }
    NSDictionary *userInfo = @{ USER_FIRSTNAME_KEY: [nameArray objectAtIndex:0],
                                USER_LASTNAME_KEY: [nameArray  objectAtIndex:1],
                                USER_PROFILE_IMAGE_KEY : thisUser.profileImageURLString,
                                USER_EMAIL_KEY: thisUser.email,
                                USER_PROFILE_IMAGE_KEY: thisUser.profileImageURLString,
                                USERNAME_KEY: thisUser.usernameString,
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
            NSLog(@"USER DOES EXIST");
            [[UserInSession shared] setCurrentUser:snapshot.data];
            [self.sharedUserDelegate segueToAppUponLogin];
        }
        else{
            NSLog(@"THIS USER DOESNT EXIST, ERROR IS: %@", error);
            }
        }];
    }
}


- (void)registrationCheck: (NSString *)eventName withUserID:(NSString *)userID
{
    __block BOOL wasRegistered = NO;
    FIRCollectionReference *eventsCollectionRef = [self.database collectionWithPath:DATABASE_EVENTS_COLLECTION];
    FIRQuery *queryToGetCurrentEvent = [eventsCollectionRef queryWhereField:@"Registered Users" arrayContains:userID];
    
    [queryToGetCurrentEvent getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error retrieving event that has this array of registered users");
        }
        else{
            for (FIRDocumentSnapshot *document in snapshot.documents){
                
                if ([document.data[@"Event Name"] isEqualToString:eventName]){
                    wasRegistered = YES;
                    [self.registrationDelegate checkForUserRegistrationDelegateMethod:wasRegistered];
                    
                }
            }
        }
    }];
}



- (void)userRegisteredForEvent: (NSString *)eventName
{
    __block FIRDocumentReference *eventToEditReference;
    FIRQuery *eventsQuery =
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] queryWhereField:EVENT_NAME_KEY isEqualTo:eventName];
    
    [eventsQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Erorr getting the event user registered for");
        }
        else{
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                eventToEditReference = [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] documentWithPath:document.documentID];
            }
            [eventToEditReference updateData:@{
                                        @"Attendance": [FIRFieldValue fieldValueForIntegerIncrement:1],
                                        @"Registered Users": [FIRFieldValue fieldValueForArrayUnion:@[[FIRAuth auth].currentUser.uid]]
                                        }];
            NSLog(@"Successfully registered, increased attendance count, and added to registered users array");
        }
    }];
}


- (void)unregisterUser: (NSString *)eventName
{
    __block FIRDocumentReference *eventToEditReference;
    FIRQuery *eventsQuery =
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] queryWhereField:EVENT_NAME_KEY isEqualTo:eventName];
    
    [eventsQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Erorr getting the event user registered for");
        }
        else{
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                eventToEditReference = [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] documentWithPath:document.documentID];
            }
            [eventToEditReference updateData:@{
                                               @"Attendance": [FIRFieldValue fieldValueForIntegerIncrement:-1],
                                               @"Registered Users": [FIRFieldValue fieldValueForArrayRemove:@[[FIRAuth auth].currentUser.uid]]
                                               }];
            NSLog(@"Successfully unregistered, decreased attendance count, and removed user from registered users");
        }
    }];
}



@end
