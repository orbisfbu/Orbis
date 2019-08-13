//
//  CreateEventViewController.h
//  Pitch
//
//  Created by ezietz on 7/23/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddEventToMapDelegate
-(void)refreshAfterEventCreation;
@end

@interface CreateEventViewController : UIViewController
@property (nonatomic, weak) id<AddEventToMapDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@end

NS_ASSUME_NONNULL_END
