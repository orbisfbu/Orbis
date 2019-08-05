//
//  EventAnnotation.m
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventAnnotation.h"
#import "Event.h"

@implementation EventAnnotation
@dynamic image;

- (id)initWithAnnotationWithImageWithEvent:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier withEvent:(Event *)thisEvent {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image
        
    }
    return self;
}

@end
