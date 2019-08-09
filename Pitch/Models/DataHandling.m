//
//  DataHandling.m
//  Pitch
//
//  Created by sbernal0115 on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DataHandling.h"
#import <FirebaseStorageUI.h>
#import <SDWebImage/UIImageView+WebCache.h>

//constants for database access to nodes and their children
static NSString * const DATABASE_USERS_COLLECTION = @"users";
static NSString * const DATABASE_EVENTS_COLLECTION = @"events";
//constants for event creation that correspond to fields in database
static NSString * const EVENT_NAME_KEY = @"Event Name";
static NSString * const EVENT_CREATOR_KEY = @"Created By";
static NSString * const EVENT_START_DATE_KEY = @"Start Date";
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
static NSString * const MEDIA_KEY = @"Media";
//Filter dictionary keys
static NSString * const FILTER_AGE_KEY = @"Age Restriction";
static NSString * const FILTER_VIBES_KEY = @"Vibes";
static NSString * const FILTER_DISTANCE_KEY = @"Distance";
static NSString * const FILTER_MINPEOPLE_KEY = @"Min People";
static NSString * const FILTER_MAXPEOPLE_KEY = @"Max People";

@interface DataHandling()
@property (nonatomic, readwrite) FIRFirestore *database;
@property (nonatomic, readwrite) FIRStorage *storage;
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
    // Get a reference to the storage service using the default Firebase App
    self.storage = [FIRStorage storage];
    return self;
}

- (void) updateUserBio:(NSString *)userBioUpdate withCompletion:(void (^) (BOOL succeeded))completion {
    NSString *userID = [UserInSession shared].sharedUser.ID;
    FIRDocumentReference *userInfoRef = [[self.database collectionWithPath:DATABASE_USERS_COLLECTION] documentWithPath:userID];
    [userInfoRef updateData:@{USER_BIO_KEY:userBioUpdate} completion:^(NSError * _Nullable error) {
        if (error!= nil){
            NSLog(@"Error updating bio; %@", error);
            completion(nil);
        }
        else {
            NSLog(@"Bio successfully updated");
            completion(YES);
        }
    }];
}

- (void)updateProfileImage:(UIImage*)imageToUpload withUserID:(NSString *)userID withCompletion:(void (^) (NSString *createdProfileImageURLString))completion {
    NSString *pathToProfileImage = [NSString stringWithFormat:@"users/%@/profileImage.jpg", userID];
    //document reference used to update user profileImageURLString in database
    FIRDocumentReference *userDocumentRef = [[self.database collectionWithPath:DATABASE_USERS_COLLECTION] documentWithPath:userID];
    // Data in memory
    NSData *data = UIImageJPEGRepresentation(imageToUpload, 0.8);
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [self.storage reference];
    FIRStorageReference *checkForExistanceRef = [storageRef child:pathToProfileImage];
    FIRStorageReference *deleteRef = [storageRef child:pathToProfileImage];
    [checkForExistanceRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
        if (error != nil) {
            if (error.code == FIRStorageErrorCodeObjectNotFound){
                NSLog(@"PROFILE IMAGE DIDNT EXIST, WILL UPLOAD FOR FIRST TIME NOW");
            }
            
        } else {
            // Delete the old user profile image
            [deleteRef deleteWithCompletion:^(NSError *error){
                if (error != nil) {
                    NSLog(@"THERE WAS AN ERROR DELETING OLD PROFILE IMAGE");
                    switch (error.code) {
                        case FIRStorageErrorCodeObjectNotFound:
                            NSLog(@"THE FILE YOU ARE TRYING TO DELETE DOESNT EXIST");
                            break;
                    }
                } else {
                    NSLog(@"SUCCESSFULLY DELETED OLD PROFILE IMAGE");
                }
            }];
        }
        
        
        FIRStorageUploadTask *uploadTask = [checkForExistanceRef putData:data
                                                                metadata:nil
                                                              completion:^(FIRStorageMetadata *metadata,
                                                                           NSError *error) {
                                                                  if (error != nil) {
                                                                      switch (error.code) {
                                                                              
                                                                          case FIRStorageErrorCodeObjectNotFound:
                                                                              NSLog(@"UPLOAD REACHED SOME ERROR, doesn't exist");
                                                                              break;
                                                                      }
                                                                  } else {
                                                                      // You can also access to download URL after upload.
                                                                      [checkForExistanceRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                                                          if (error != nil) {
                                                                              NSLog(@"THERE WAS AN ERROR DOWNLOADING STORED IMAGE URL");
                                                                              completion(nil);
                                                                          } else {
                                                                              //convert to URL string since this is how User object stores it
                                                                              //this ensures profileImageURLString is also updated
                                                                              completion(URL.absoluteString);
                                                                          }
                                                                      }];
                                                                  }
                                                              }];
        
    }];
    
}


- (void)setUserProfileImage:(UIImageView *)profile_imageImageView{
    NSString *userID = [UserInSession shared].sharedUser.ID;
    FIRStorageReference *storageRef = [self.storage reference];
    FIRStorageReference *userProfileImageRef = [storageRef child:[NSString stringWithFormat:@"users/%@/profileImage.jpg", userID]];
    UIImage *placeholderImage = [UIImage imageNamed:@"default_profile"];
    // Fetch the download URL
    [userProfileImageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
        if (error != nil) {
            NSLog(@"ERROR GETTING PROFILE IMAGE FROM STORAGE");
            NSLog(@"THIS IS THE ERROR CODE: %ln", (long)error.code);
        } else {
            //successfully setImageView
            [profile_imageImageView sd_setImageWithURL:URL placeholderImage:placeholderImage];
        }
    }];
}

- (void)uploadEventMainImage:(UIImage*)imageToUpload withEventID:(NSString *)eventID {
    FIRDocumentReference *eventInfoRef = [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] documentWithPath:eventID];
    NSData *data = UIImageJPEGRepresentation(imageToUpload, 0.8);
    FIRStorageReference *storageRef = [self.storage reference];
    FIRStorageReference *eventMainImageRef = [storageRef child:[NSString stringWithFormat:@"events/%@/coverImage.jpg", eventID]];
    [eventMainImageRef putData:data metadata:nil
                    completion:^(FIRStorageMetadata *metadata, NSError *error) {
                        if (error != nil) {
                            NSLog(@"UPLOAD REACHED SOME ERROR");
                            switch (error.code) {
                                case FIRStorageErrorCodeObjectNotFound:
                                    NSLog(@"Upload event mainImage file doesn't exist error");
                                    break;
                            }
                        } else {
                            [eventMainImageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                if (error != nil) {
                                    NSLog(@"THERE WAS AN ERROR DOWNLOADING STORED IMAGE URL");
                                } else {
                                    //convert to URL string since this is how User object stores it
                                    //this ensures profileImageURLString is also updated
                                    [eventInfoRef updateData:@{EVENT_IMAGE_URL_KEY: URL.absoluteString}];
                                    //if success then go to explore view controller
                                }
                            }];
                        }
                    }];
}

- (void)uploadAdditionalMedia:(NSArray *)mediaToUpload toEvent:(NSString *)eventID {
    FIRStorageReference *storageRef = [self.storage reference];
    int i = 0;
    for (UIImage *image in mediaToUpload) {
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        FIRStorageReference *eventMainImageRef = [storageRef child:[NSString stringWithFormat:@"events/%@/additionalImage_%i.jpg", eventID, i]];
        [eventMainImageRef putData:data metadata:nil
                        completion:^(FIRStorageMetadata *metadata, NSError *error) {
                            if (error != nil) {
                                NSLog(@"UPLOAD REACHED SOME ERROR");
                                switch (error.code) {
                                    case FIRStorageErrorCodeObjectNotFound:
                                        NSLog(@"Upload additional media file doesn't exist error");
                                        break;
                                }
                            } else {
                                [eventMainImageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                    if (error != nil) {
                                        NSLog(@"THERE WAS AN ERROR DOWNLOADING STORED IMAGE URL");
                                    } else {
                                        NSLog(@"SUCCESSFULLY UPLOADED IMAGE");
                                    }
                                }];
                            }
                        }];
        i++;
    }
}

- (void) getEventsAttendedByUser {
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting events from database: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 if ([document.data[@"Registered Users"] containsObject:[UserInSession shared].sharedUser.ID]) {
                     Event *attendedEventToAdd = [[Event alloc ]initWithDictionary:document.data];
                     NSDate *currentDate = [[NSDate alloc] init];
                     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                     [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                     [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                     NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
                     NSDate *formattedCurrentDate = [dateFormatter dateFromString:currentDateString];
                     NSDate *startDate = [dateFormatter dateFromString:attendedEventToAdd.startDateString];
                     NSComparisonResult comparisonResult = [formattedCurrentDate compare:startDate];
                     if (comparisonResult == NSOrderedDescending ) { //The current Date is earlier in time than start Date
                         [[UserInSession shared].eventsAttendedMArray addObject:attendedEventToAdd]; // event will be added to NSMutableArray because event was in the past and user was registered
                     }
                 }
             }
         }
         NSLog(@"Number of events attended by (USER PAGE): %lu", [UserInSession shared].eventsAttendedMArray.count);
     }];
}

- (void) getEventsCreatedByUser {
    [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting events from database: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 if ([document.data[@"Created By"] isEqualToString:[UserInSession shared].sharedUser.nameString]) {
                     Event *createdEventToAdd = [[Event alloc ]initWithDictionary:document.data];
                     [[UserInSession shared].eventsCreatedMArray addObject:createdEventToAdd];
                 }
             }
         }
         NSLog(@"Number of events created by (USER): %lu", [UserInSession shared].eventsCreatedMArray.count);
     }];
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
    long distanceFilter = [filters[FILTER_DISTANCE_KEY] longValue];
    
    long minNumPeopleFilter = [filters[FILTER_MINPEOPLE_KEY] longValue];
    long maxNumPeopleFilter = [filters[FILTER_MAXPEOPLE_KEY] longValue];
    
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
                CLLocationDistance distanceInKilometers = [thisEventLocation distanceFromLocation:userLocation]/1000;
                
                NSLog(@"THIS IS THE DISTANCE BETWEEN USER AND EVENT: %f", distanceInKilometers);
                if ([vibesFilterSet isSubsetOfSet:thisEventVibeSet] && distanceInKilometers <= distanceFilter){
                    
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
        if (![song.albumName isEqualToString:@"plus"]) {
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
                                EVENT_REGISTERED_USERS_KEY: event.registeredUsersArray,
                                MUSIC_QUEUE_KEY: songQueue,
                                EVENT_START_DATE_KEY: event.startDateString
                                };
    
    __block FIRDocumentReference *eventRef = [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] addDocumentWithData:eventInfo completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error adding document: %@", error);
        } else {
            NSLog(@"Document added with ID: %@", eventRef.documentID);
            if (event.mediaArray.count > 0) {
                [self uploadEventMainImage:event.mediaArray[event.mediaArray.count - 1] withEventID:eventRef.documentID];
                [event.mediaArray removeObjectAtIndex:event.mediaArray.count - 1];
                if (event.mediaArray.count > 0) {
                    [self uploadAdditionalMedia:event.mediaArray toEvent:eventRef.documentID];
                }
            }
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
                                USER_BACKGROUND_KEY: thisUser.profileBackgroundImageURLString,
                                USER_EMAIL_KEY: thisUser.email,
                                USERNAME_KEY: thisUser.usernameString,
                                USER_BIO_KEY: thisUser.userBioString
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
            [[UserInSession shared] setCurrentUser:snapshot.data withUserID:userID];
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
