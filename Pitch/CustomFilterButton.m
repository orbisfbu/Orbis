//
//  CustomFilterButton.m
//  Pitch
//
//  Created by sbernal0115 on 8/8/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "CustomFilterButton.h"

@implementation CustomFilterButton
+ (instancetype)customButtonWithCustomArgument:(id)customValue {
    CustomFilterButton *customButton = [super buttonWithType:UIButtonTypeSystem];
    customButton.resultsWereFound = YES;
    return customButton;
}
@end
