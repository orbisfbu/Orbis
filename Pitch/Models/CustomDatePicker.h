//
//  CustomDatePicker.h
//  Pitch
//
//  Created by mariobaxter on 8/1/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *FLOUNDS_DATE_PICKER_VALUE_CHANGED_NOTIFICATION;

NS_ASSUME_NONNULL_BEGIN

@interface CustomDatePicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSDate *currSelectedTime;
@property (nonatomic) BOOL showTimeIn24HourFormat;
@property (nonatomic, strong) UIFont *displayFont;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *backgroundColor;

-(void)setShowTimeIn24HourFormat:(BOOL)showTimeIn24HourFormat
           withPickerViewRefresh:(BOOL)refreshPickerView;

-(void)setDisplayedTime:(NSDate *)displayTimeDate
               animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
