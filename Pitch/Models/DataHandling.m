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
//Filter dictionary keys
static NSString * const FILTER_AGE_KEY = @"Age Restriction";
static NSString * const FILTER_VIBES_KEY = @"Vibes";
static NSString * const FILTER_DISTANCE_KEY = @"Distance";
static NSString * const FILTER_MINPEOPLE_KEY = @"Min People";
static NSString * const FILTER_MAXPEOPLE_KEY = @"Max People";

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

- (void)getFilteredEventsFromDatabase: (NSDictionary*)filters userLocation:(CLLocation *)userLocation {
    NSMutableArray <Event *> *filteredEventsArray = [[NSMutableArray alloc] init];
    int ageRestrictionFilter = [filters[FILTER_AGE_KEY] intValue];
    NSMutableSet *vibesFilterSet = filters[FILTER_VIBES_KEY];
    int distanceFilter = [filters[FILTER_DISTANCE_KEY] intValue];
    int minNumPeopleFilter = [filters[FILTER_MINPEOPLE_KEY] intValue];
    int maxNumPeopleFilter = [filters[FILTER_MAXPEOPLE_KEY] intValue];
    FIRCollectionReference *eventRef = [self.database collectionWithPath:DATABASE_EVENTS_COLLECTION];
    FIRQuery *filterEventsQuery;
    if (ageRestrictionFilter != 0){
        filterEventsQuery = [[[eventRef queryWhereField:EVENT_AGE_RESTRICTION_KEY isEqualTo:@(ageRestrictionFilter)] queryWhereField:EVENT_ATTENDANCE_KEY isGreaterThanOrEqualTo:@(minNumPeopleFilter)] queryWhereField:EVENT_ATTENDANCE_KEY isLessThanOrEqualTo:@(maxNumPeopleFilter)];
    }
    else{
        filterEventsQuery = [[eventRef queryWhereField:EVENT_ATTENDANCE_KEY isGreaterThanOrEqualTo:@(minNumPeopleFilter)] queryWhereField:EVENT_ATTENDANCE_KEY isLessThanOrEqualTo:@(maxNumPeopleFilter)];
    }
    [filterEventsQuery getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting filtered events from database: %@", error);
        } else {
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                NSArray *thisEventVibesArray = document.data[FILTER_VIBES_KEY];
                NSMutableSet *thisEventVibeSet = [NSMutableSet setWithArray:thisEventVibesArray];
                NSArray *locationComponents = [document.data[EVENT_LOCATION_KEY] componentsSeparatedByString:@" "];
                NSNumber  *latitudeNum = [NSNumber numberWithFloat: [[locationComponents objectAtIndex:0] floatValue]];
                NSNumber  *longitudeNum = [NSNumber numberWithFloat: [[locationComponents objectAtIndex:1] floatValue]];
                CLLocationCoordinate2D thisEventCoordinate = CLLocationCoordinate2DMake(latitudeNum.floatValue, longitudeNum.floatValue);
                CLLocation *thisEventLocation = [[CLLocation alloc] initWithLatitude:thisEventCoordinate.latitude longitude:thisEventCoordinate.longitude];
                CLLocationDistance distanceInMeters = [thisEventLocation distanceFromLocation:userLocation];
                NSLog(@"THIS IS THE DISTANCE BETWEEN USER AND EVENT: %f", distanceInMeters/1000);
                if ([thisEventVibeSet isSubsetOfSet:vibesFilterSet] && distanceInMeters/1000 <= distanceFilter){
                    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithDictionary:document.data];
                    [eventDict setValue:document.documentID forKey:@"ID"];
                    Event *eventToAdd = [[Event alloc] initWithDictionary:eventDict];
                    [filteredEventsArray addObject:eventToAdd];
                }
            }
        }
        [self.filteredEventsDelegate refreshFilteredEventsDelegateMethod:filteredEventsArray];
    }];
}


- (void)addEventToDatabase:(Event *)event {
    NSMutableDictionary *songQueue = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (Song *song in event.musicQueue) {
        if (![song.albumName isEqualToString:@"default_album"]) {
            NSMutableDictionary *songDict = [[NSMutableDictionary alloc] init];
            [songDict setValue:song.title forKey:@"Title"];
            [songDict setValue:song.artistName forKey:@"Artist Name"];
            [songDict setValue:song.albumName forKey:@"Album Name"];
            [songDict setValue:@(0) forKey:@"numLikes"];
            [songDict setValue:[[NSArray alloc] init] forKey:@"userIDs"];
            [songQueue setValue:songDict forKey:[NSString stringWithFormat:@"%i", i]];
            i++;
        }
    }
    NSDictionary *eventInfo = @{
                                EVENT_CREATOR_KEY: [UserInSession shared].sharedUser.nameString,
                                EVENT_ATTENDANCE_KEY: @(event.eventAttendanceCount),
                                EVENT_IMAGE_URL_KEY: event.eventImageURLString,
                                EVENT_AGE_RESTRICTION_KEY: @(event.eventAgeRestriction),
                                EVENT_LOCATION_KEY: event.eventLocationString,
                                EVENT_DESCRIPTION_KEY: event.eventDescription,
                                EVENT_NAME_KEY: event.eventName,
                                EVENT_VIBES_KEY: event.eventVibesArray,
                                EVENT_REGISTERED_USERS_KEY: [NSMutableArray new],
                                MUSIC_QUEUE_KEY: songQueue
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

- (void)loadUserInfoAndApp: (NSString *)userID{ {
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

- (void) getEvent:(NSString *)eventID withCompletion:(void (^) (Event *event))completion {
    FIRDocumentReference *docRef = [[self.database collectionWithPath:@"events"] documentWithPath:eventID];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting event with ID: %@: ", eventID);
            completion(nil);
        } else {
            NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithDictionary:snapshot.data];
            [eventDict setValue:snapshot.documentID forKey:@"ID"];
            NSMutableArray *songsArray = [[NSMutableArray alloc] init];
            for (NSString *songIndex in snapshot.data[@"Music Queue"]) {
                [songsArray addObject:[[Song alloc] initWithDictionary:snapshot.data[@"Music Queue"][songIndex]]];
            }
            [eventDict setValue:songsArray forKey:@"Music Queue"];
            completion([[Event alloc] initWithDictionary:eventDict]);
        }
    }];
}

- (void)registerUserToEvent:(Event *)event {
    __block FIRDocumentReference *eventRef;
    FIRCollectionReference *eventsRef = [self.database collectionWithPath:@"events"];
    eventRef = [eventsRef documentWithPath:event.ID];
    [eventRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting the event user registered for");
        } else {
            [eventRef updateData:@{@"Attendance": [FIRFieldValue fieldValueForIntegerIncrement:1],
                                   @"Registered Users": [FIRFieldValue fieldValueForArrayUnion:@[[FIRAuth auth].currentUser.uid]]
                                   }];
            NSLog(@"Successfully registered, increased attendance count, and added to registered users array");
        }
    }];
}

- (void) unregisterUser:(Event *)event {
    __block FIRDocumentReference *eventRef;
    FIRCollectionReference *eventsRef = [self.database collectionWithPath:@"events"];
    eventRef = [eventsRef documentWithPath:event.ID];
    [eventRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting the event user registered for");
        } else {
            [eventRef updateData:@{@"Attendance": [FIRFieldValue fieldValueForIntegerIncrement:-1],
                                   @"Registered Users": [FIRFieldValue fieldValueForArrayRemove:@[[FIRAuth auth].currentUser.uid]]
                                   }];
            NSLog(@"Successfully unregistered, decreased attendance count, and removed user from registered users");
        }
    }];
}

- (void) user:(NSString *)userID didLikeSong:(Song *)song atIndex:(NSInteger)index atEvent:(NSString *)eventID {
    __block FIRDocumentReference *eventRef;
    FIRCollectionReference *eventsRef = [self.database collectionWithPath:@"events"];
    eventRef = [eventsRef documentWithPath:eventID];
    [eventRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting the event");
        } else {
            [eventRef updateData:@{[NSString stringWithFormat:@"Music Queue.%li.numLikes", index]:[FIRFieldValue fieldValueForIntegerIncrement:+1],
                                   [NSString stringWithFormat:@"Music Queue.%li.userIDs", index]:[FIRFieldValue fieldValueForArrayUnion:@[[FIRAuth auth].currentUser.uid]]}];
        }
    }];
}

- (void) user:(NSString *)userID didUnlikeSong:(Song *)song atIndex:(NSInteger)index atEvent:(NSString *)eventID {
    __block FIRDocumentReference *eventRef;
    FIRCollectionReference *eventsRef = [self.database collectionWithPath:@"events"];
    eventRef = [eventsRef documentWithPath:eventID];
    [eventRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting the event");
        } else {
            [eventRef updateData:@{[NSString stringWithFormat:@"Music Queue.%li.numLikes", index]:[FIRFieldValue fieldValueForIntegerIncrement:-1],
                                   [NSString stringWithFormat:@"Music Queue.%li.userIDs", index]:[FIRFieldValue fieldValueForArrayRemove:@[[FIRAuth auth].currentUser.uid]]}];
        }
    }];
}

@end
