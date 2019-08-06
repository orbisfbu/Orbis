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
static NSString * const EVENT_REGISTERED_USERS_KEY = @"Registered Users";
//constants for user addition to database
static NSString * const USER_FIRSTNAME_KEY = @"First Name";
static NSString * const USER_LASTNAME_KEY = @"Last Name";
static NSString * const USER_EMAIL_KEY = @"Email";
static NSString * const USER_PROFILE_IMAGE_KEY = @"ProfileImageURL";
static NSString * const USERNAME_KEY = @"Username";
static NSString * const USER_BACKGROUND_KEY = @"BackgroundImageURL";
//set this text to some default text or something like "change bio now!"
static NSString * const USER_BIO_KEY = @"Bio";
static NSString * const MUSIC_QUEUE_KEY = @"Music Queue";

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
    NSMutableArray <Event*> *eventsArray = [[NSMutableArray alloc] init];
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting events from database: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithDictionary:document.data];
                 [eventDict setValue:document.documentID forKey:@"ID"];
                 Event *eventToAdd = [[Event alloc] initWithDictionary:eventDict];
                 [eventsArray addObject:eventToAdd];
             }
         }
         [self.delegate refreshEventsDelegateMethod:eventsArray];
     }];
}


- (void)getFilteredEventsFromDatabase: (NSDictionary*)filters{
    NSMutableArray <Event *> *filteredEventsArray = [[NSMutableArray alloc] init];
    int ageRestriction = [filters[@"Age Restriction"] intValue];
    NSMutableSet *vibesSet = filters[@"Vibes"];
    int distance = [filters[@"Distance"] intValue];
    int minNumPeople = [filters[@"Min People"] intValue];
    int maxNumPeople = [filters[@"Max People"] intValue];
    FIRCollectionReference *eventRef = [self.database collectionWithPath:DATABASE_EVENTS_COLLECTION];
    FIRQuery *filterEventsQuery;
    
    if (ageRestriction != 0){
        
        filterEventsQuery = [[[eventRef queryWhereField:@"Age Restriction" isEqualTo:@(ageRestriction)] queryWhereField:@"Attendance" isGreaterThanOrEqualTo:@(minNumPeople)] queryWhereField:@"Attendance" isLessThanOrEqualTo:@(maxNumPeople)];
    }
    
    else{
        filterEventsQuery = [[eventRef queryWhereField:@"Attendance" isGreaterThanOrEqualTo:@(minNumPeople)] queryWhereField:@"Attendance" isLessThanOrEqualTo:@(maxNumPeople)];
    }
    
    [filterEventsQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting filtered events from database: %@", error);
            
        } else {
            
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                
                NSArray *thisVibesArray = document.data[@"Vibes"];
                NSMutableSet *vibesSetToCompare = [NSMutableSet setWithArray:thisVibesArray];
                
                if ([vibesSetToCompare isEqualToSet:vibesSet]){
                    Event *eventToAdd = [[Event alloc] initWithDictionary:document.data];
                    
                    [filteredEventsArray addObject:eventToAdd];
                }
            }
        }
        
        [self.filteredEventsDelegate refreshFilteredEventsDelegateMethod:filteredEventsArray];
    }];
}


- (void)addEventToDatabase:(Event *)definedEvent{
    NSDictionary *eventInfo = @{
                                EVENT_CREATOR_KEY: [UserInSession shared].sharedUser.nameString,
                                EVENT_ATTENDANCE_KEY: @(definedEvent.eventAttendanceCount),
                                EVENT_IMAGE_URL_KEY: definedEvent.eventImageURLString,
                                EVENT_AGE_RESTRICTION_KEY: @(definedEvent.eventAgeRestriction),
                                EVENT_LOCATION_KEY: definedEvent.eventLocationString,
                                EVENT_DESCRIPTION_KEY: definedEvent.eventDescription,
                                EVENT_NAME_KEY: definedEvent.eventName,
                                EVENT_VIBES_KEY: definedEvent.eventVibesArray,
                                EVENT_REGISTERED_USERS_KEY: [NSMutableArray new],
                                MUSIC_QUEUE_KEY: definedEvent.musicQueue
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


- (void)getInfoForEventAnnotionWithTitle: (NSString *)title withCoordinates: (CLLocationCoordinate2D)coordinates{
    __block NSDictionary *eventInfoForAnnotation;
    NSString *coordinateString = [NSString stringWithFormat:@"%.5f %.5f", coordinates.latitude, coordinates.longitude];
    FIRQuery *eventsForAnnotationQuery =
    [[[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] queryWhereField:EVENT_NAME_KEY isEqualTo:title] queryWhereField:EVENT_LOCATION_KEY isEqualTo:coordinateString];
    [eventsForAnnotationQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Error getting the event info for the annotation clicked");
        }
        else{
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                eventInfoForAnnotation = document.data;
            }
            [self.eventAnnotationDelegate eventDataForDetailedView:eventInfoForAnnotation];
        }
    }];
}


- (void)userRegisteredForEvent: (NSString *)eventName
{
    __block FIRDocumentReference *eventToEditReference;
    FIRQuery *getEventsWithThisNameQuery =
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] queryWhereField:EVENT_NAME_KEY isEqualTo:eventName];
    
    [getEventsWithThisNameQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
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
    FIRQuery *getEventsWithThisNameQuery =
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] queryWhereField:EVENT_NAME_KEY isEqualTo:eventName];
    
    [getEventsWithThisNameQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
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
