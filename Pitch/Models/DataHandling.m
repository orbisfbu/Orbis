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


- (void)uploadEventMainImage:(UIImage*)imageToUpload withEventID:(NSString *)eventID withCompletion:(void (^) (BOOL uploadSuccess))completion {
    FIRDocumentReference *eventInfoRef = [[self.database collectionWithPath:DATABASE_EVENTS_COLLECTION] documentWithPath:eventID];
    // Data in memory
    NSData *data = UIImageJPEGRepresentation(imageToUpload, 0.8);
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [self.storage reference];
    //use below line when uploading gallery images
    //NSString *randomImageFileName = [[NSUUID alloc] init].UUIDString;
    // Create a reference to the file you want to upload
    FIRStorageReference *eventMainImageRef = [storageRef child:[NSString stringWithFormat:@"eventMainImages/%@/mainImage.jpg", eventID]];
    FIRStorageUploadTask *uploadTask = [eventMainImageRef putData:data
                                                       metadata:nil
                                                     completion:^(FIRStorageMetadata *metadata,
                                                                  NSError *error) {
                                                         if (error != nil) {
                                                             NSLog(@"UPLOAD REACHED SOME ERROR");
                                                             switch (error.code) {
                                                                 case FIRStorageErrorCodeObjectNotFound:
                                                                     // File doesn't exist
                                                                     break;

                                                                 case FIRStorageErrorCodeUnauthorized:
                                                                     // User doesn't have permission to access file
                                                                     break;
                                                                 case FIRStorageErrorCodeCancelled:
                                                                     // User canceled the upload
                                                                     break;
                                                                 case FIRStorageErrorCodeUnknown:
                                                                     // Unknown error occurred, inspect the server response
                                                                     break;
                                                             }
                                                         } else {
                                                             [eventMainImageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                                                 if (error != nil) {
                                                                     NSLog(@"THERE WAS AN ERROR DOWNLOADING STORED IMAGE URL");
                                                                     completion(NO);
                                                                 } else {
                                                                     //convert to URL string since this is how User object stores it
                                                                     //this ensures profileImageURLString is also updated
                                                                     [eventInfoRef updateData:@{EVENT_IMAGE_URL_KEY: URL.absoluteString
                                                                                               }];
                                                                     //if success then go to explore view controller
                                                                     completion(YES);
                                                                 }
                                                             }];
                                                         }
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
