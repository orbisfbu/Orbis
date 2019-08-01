//
//  SearchResult.h
//  Pitch


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResult : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSString *) getName;
- (NSString *) getAddress;
- (NSString *) getCity;
- (NSString *) getState;
- (NSString *) getPostalCode;
- (NSString *) getIconURLString;
- (CLLocationCoordinate2D) getCoordinates;

@end

NS_ASSUME_NONNULL_END
