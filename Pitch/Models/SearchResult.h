//
//  SearchResult.h
//  Pitch
//
//  Created by ezietz on 8/1/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResult : NSObject

- (instancetype) initWithDictionary: (NSDictionary *) dict;
- (NSString *) getName;
- (CLLocationCoordinate2D) getCoordinates;
- (NSString *) getAddress;
- (NSString *) getCity;
- (NSString *) getState;
- (NSString *) getPostalCode;
- (NSString *) getIconURLString;

@end

NS_ASSUME_NONNULL_END
