//
//  Event.m
//  Pitch
//
//  Created by sbernal0115 on 7/18/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "Event.h"

@implementation Event


//after iterating through all of the events in the Events node in firebase,
//this method will be used to instantiate an array of events that will be used
//to populate the map and also provide a list of events
- (instancetype)initWithDictionary:(NSDictionary *)snapshotDictionary {
    self = [super init];
    if (self) {
        self.eventCreator = snapshotDictionary[@"Created By"];
        self.eventName = snapshotDictionary[@"Event Name"];
        self.eventVibesArray = snapshotDictionary[@"Vibes"];
        self.eventPollsArray = snapshotDictionary[@"Polls"] ;
        self.eventHasMusic = snapshotDictionary[@"Has Music"];
        self.eventAttendanceCount = [snapshotDictionary[@"Attendance"] intValue];
        self.eventImageURLString = snapshotDictionary[@"Image"];
        self.eventDescription = snapshotDictionary[@"Description"];
        self.eventAgeRestriction = [snapshotDictionary[@"Age Restriction"] intValue];
        //location in the data base will be a string with latitude and longitude string separated with a space character
        NSArray *locationComponents = [snapshotDictionary[@"Location"] componentsSeparatedByString:@" "];
        NSString *latitudeString = [locationComponents objectAtIndex:0];
        NSString *longitudeString = [locationComponents objectAtIndex:1];
        NSNumber  *latitudeNum = [NSNumber numberWithInteger: [latitudeString integerValue]];
        NSNumber  *longitudeNum = [NSNumber numberWithInteger: [longitudeString integerValue]];
        NSLog([NSString stringWithFormat:@"This is the latitude and longitude: %@, %@", latitudeNum, longitudeNum]);
        self.eventCoordinates = CLLocationCoordinate2DMake(latitudeNum.floatValue, longitudeNum.floatValue);
    }
    return self;
}


@end
