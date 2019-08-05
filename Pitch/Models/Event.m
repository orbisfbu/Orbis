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
        self.eventImageURLString = snapshotDictionary[@"ImageURL"];
        self.eventDescription = snapshotDictionary[@"Description"];
        self.eventLocationString = snapshotDictionary[@"Location"];
        self.eventVibesArray = [NSMutableArray arrayWithArray:snapshotDictionary[@"Vibes"]];
        self.minNumPeople = [snapshotDictionary[@"MinPeople"] intValue];
        self.maxNumPeople = [snapshotDictionary[@"MaxPeople"] intValue];
        self.eventAgeRestriction = [snapshotDictionary[@"Age Restriction"] intValue];
        self.eventAttendanceCount = [snapshotDictionary[@"Attendance"] intValue];
        //formatting location string
        NSArray *locationComponents = [self.eventLocationString componentsSeparatedByString:@" "];
        NSString *latitudeString = [locationComponents objectAtIndex:0];
        NSString *longitudeString = [locationComponents objectAtIndex:1];
        NSNumber  *latitudeNum = [NSNumber numberWithFloat: [latitudeString floatValue]];
        NSNumber  *longitudeNum = [NSNumber numberWithFloat: [longitudeString floatValue]];
        self.eventCoordinates = CLLocationCoordinate2DMake(latitudeNum.floatValue, longitudeNum.floatValue);
        
        self.musicQueue = snapshotDictionary[@"Music Queue"];
        
    }
    return self;
}


@end
