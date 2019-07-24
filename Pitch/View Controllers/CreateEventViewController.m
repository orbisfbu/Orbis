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
#import "DataHandling.h"

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
@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *eventDefinition = @{
                                      @"Created By": @"Sebastian",
                                      @"Event Name": @"TestName",
                                      @"Has Music": @"YES",
                                      @"Attendance": @"4",
                                      @"ImageURL": @"testingURL",
                                      @"Description": @"testing",
                                      @"Age Restriction": @"18",
                                      @"Location": @"37.777596 -122.458708"
                                      };
    
    Event *eventToAdd = [[Event alloc] initWithDictionary:eventDefinition];
    
    [[DataHandling shared] addEventToDatabase:eventToAdd];
    
    
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
