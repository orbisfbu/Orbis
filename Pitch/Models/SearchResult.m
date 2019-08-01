//
//  SearchResult.m
//  Pitch

#import "SearchResult.h"

@interface SearchResult ()

@property (strong, nonatomic) NSString *name;
@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *iconURLStringPrefix;
@property int iconSize;
@property (strong, nonatomic) NSString *iconURLStringSuffix;

@end

@implementation SearchResult

- (instancetype) initWithDictionary: (NSDictionary *) dict {
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.address = dict[@"location"][@"address"];
        self.city = dict[@"location"][@"city"];
        self.state = dict[@"location"][@"state"];
        self.postalCode = dict[@"location"][@"postalCode"];
        double lat = [dict[@"location"][@"lat"] doubleValue];
        double lon = [dict[@"location"][@"lng"] doubleValue];
        self.coordinates = CLLocationCoordinate2DMake(lat, lon);
//        self.iconURLStringPrefix = dict[@"categories"][0][@"icon"][@"prefix"];
//        self.iconSize = 64;
//        self.iconURLStringSuffix = dict[@"categories"][0][@"icon"][@"suffix"];
    }
    return self;
}

- (NSString *) getName {
    return self.name;
}

- (NSString *) getAddress {
    return self.address;
}

- (NSString *) getCity {
    return self.city;
}

- (NSString *) getState {
    return self.state;
}

- (NSString *) getPostalCode {
    return self.postalCode;
}

- (NSString *) getIconURLString {
    NSString *URLString = [NSString stringWithFormat:@"%@%d%@", self.iconURLStringPrefix, self.iconSize, self.iconURLStringSuffix];
    return URLString;
}

- (CLLocationCoordinate2D) getCoordinates {
    return self.coordinates;
}

@end
