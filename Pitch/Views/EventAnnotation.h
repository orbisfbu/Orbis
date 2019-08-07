//
//  EventAnnotation.h
//  Pitch
//
//  Created by sbernal0115 on 8/7/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventAnnotation : MKPointAnnotation
@property (nonatomic, strong) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *mainImageURLString;
@end

NS_ASSUME_NONNULL_END
