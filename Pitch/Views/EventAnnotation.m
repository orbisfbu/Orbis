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

- (instancetype)initWithAnnotation:(nullable id <MKAnnotation>)annotation reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    return self;
}

@end
