//
//  CreateEventViewController.h
//  Pitch
//
//  Created by ezietz on 7/23/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddEventAnnotationToMapDelegate
-(void)addThisAnnotationToMap:(EventAnnotation *)newEventAnnotation;
@end

@interface CreateEventViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, weak) id<AddEventAnnotationToMapDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
