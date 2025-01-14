//
//  Poll.h
//  Pitch
//
//  Created by ezietz on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Poll : NSObject

@property (nonatomic, strong) NSString *pollTitle;
@property (nonatomic, strong) NSString *pollOption;

@end

NS_ASSUME_NONNULL_END
