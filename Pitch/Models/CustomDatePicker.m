//
//  CustomDatePicker.m
//  Pitch
//
//  Created by mariobaxter on 8/1/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "CustomDatePicker.h"

NSString *FLOUNDS_DATE_PICKER_VALUE_CHANGED_NOTIFICATION = @"Flounds date picker changed value";


const CGFloat PICKERVIEW_SIZING_HORIZONTAL_PADDING_FACTOR = 1.5f;
const CGFloat PICKERVIEW_SIZING_VERTICAL_PADDING_FACTOR = 0.5f;
const NSInteger PICKERVIEW_HOURS_COMPONENT_INDEX = 0;
const NSInteger PICKERVIEW_MINUTES_COMPONENT_INDEX = 1;
const NSInteger PICKERVIEW_PERIOD_COMPONENT_INDEX = 2;
const NSInteger SHOW_TIME_24_NUMBER_OF_HOURS = 24;
NSString *DATE_FORMATTER_24_HOUR_DATE_FORMAT = @"HH:mm";
const NSInteger SHOW_TIME_12_NUMBER_OF_HOURS = 12;
NSString *DATE_FORMATTER_12_HOUR_DATE_FORMAT = @"h:mm:a";
const NSInteger NUMBER_OF_MINUTES = 60;
const NSInteger NUMBER_OF_PERIODS = 2;
NSString *PERIOD_AT_INDEX_0_STRING;
NSString *PERIOD_AT_INDEX_1_STRING;

@interface CustomDatePicker ()

@property (nonatomic) NSUInteger numOfComponents;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;

@end

@implementation CustomDatePicker

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initHelperFloundsDatePicker];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initHelperFloundsDatePicker];
    }
    return self;
}

-(void)initHelperFloundsDatePicker {
    self.delegate = self;
    self.dataSource = self;
    
    NSLog(@"MAKING PICKER");
    self.backgroundColor = [UIColor whiteColor];
    self.displayFont = [UIFont fontWithName:@"GothamRounded-Bold" size:20];
    self.fontColor = [UIColor blackColor];
    
    PERIOD_AT_INDEX_0_STRING = @"AM";
    PERIOD_AT_INDEX_1_STRING = @"PM";
}

-(void)setShowTimeIn24HourFormat:(BOOL)showTimeIn24HourFormat
           withPickerViewRefresh:(BOOL)refreshPickerView; {
    _showTimeIn24HourFormat = showTimeIn24HourFormat;
    if (showTimeIn24HourFormat)
    {
        self.numOfComponents = 2;
        self.dateFormatter.dateFormat = DATE_FORMATTER_24_HOUR_DATE_FORMAT;
    }
    else
    {
        self.numOfComponents = 3;
        self.dateFormatter.dateFormat = DATE_FORMATTER_12_HOUR_DATE_FORMAT;
    }
    [self reloadAllComponents];
    if (refreshPickerView)
    {
        [self setDisplayedTime:self.currSelectedTime animated:YES];
    }
}

-(NSDateFormatter *)dateFormatter {
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.timeStyle = NSDateIntervalFormatterMediumStyle;
        if (self.showTimeIn24HourFormat)
        {
            _dateFormatter.dateFormat = DATE_FORMATTER_24_HOUR_DATE_FORMAT;
        }
        else
        {
            _dateFormatter.dateFormat = DATE_FORMATTER_12_HOUR_DATE_FORMAT;
        }
    }
    return _dateFormatter;
}

-(void)setDisplayedTime:(NSDate *)displayTimeDate
               animated:(BOOL)animated {
    self.currSelectedTime = displayTimeDate;
    
    NSString *displayTimeDateAsString = [self.dateFormatter stringFromDate:displayTimeDate];
    NSArray *parsedDisplayTimeArray = [displayTimeDateAsString componentsSeparatedByString:@":"];
    
    for (NSUInteger index = 0; index < [parsedDisplayTimeArray count]; index++)
    {
        NSString *oneRowString = [parsedDisplayTimeArray objectAtIndex:index];
        NSInteger oneRowInteger = -1;
        
        if (index == PICKERVIEW_PERIOD_COMPONENT_INDEX)
        {
            oneRowInteger = [oneRowString caseInsensitiveCompare:PERIOD_AT_INDEX_0_STRING] == NSOrderedSame ? 0 : 1;
        }
        else
        {
            oneRowInteger = [oneRowString integerValue];
            if (!self.showTimeIn24HourFormat && oneRowInteger == 12)
            {
                oneRowInteger = 0;
            }
        }
        [self selectRow:oneRowInteger inComponent:index animated:animated];
    }
}

#pragma UIPickerViewDataSource
-(NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    if (self.showTimeIn24HourFormat)
    {
        if (component == PICKERVIEW_HOURS_COMPONENT_INDEX)
        {
            return SHOW_TIME_24_NUMBER_OF_HOURS;
        }
        else if (component == PICKERVIEW_MINUTES_COMPONENT_INDEX)
        {
            return NUMBER_OF_MINUTES;
        }
    }
    else
    {
        if (component == PICKERVIEW_HOURS_COMPONENT_INDEX)
        {
            return SHOW_TIME_12_NUMBER_OF_HOURS;
        }
        else if (component == PICKERVIEW_MINUTES_COMPONENT_INDEX)
        {
            return NUMBER_OF_MINUTES;
        }
        else if (component == PICKERVIEW_PERIOD_COMPONENT_INDEX)
        {
            return NUMBER_OF_PERIODS;
        }
    }
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.numOfComponents;
}

#pragma UIPickerViewDelegate
-(CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component {
    NSAttributedString *sampleAttString = [[NSAttributedString alloc]
                                           initWithString:[NSString stringWithFormat:@"%lu", (long)SHOW_TIME_24_NUMBER_OF_HOURS]
                                           attributes:@{NSFontAttributeName : self.displayFont}];
    CGFloat sampleAttStringHeight = sampleAttString.size.height;
    
    return sampleAttStringHeight + (sampleAttStringHeight * PICKERVIEW_SIZING_VERTICAL_PADDING_FACTOR);
}

-(CGFloat)pickerView:(UIPickerView *)pickerView
   widthForComponent:(NSInteger)component {
    NSAttributedString *sampleAttString = [[NSAttributedString alloc]
                                           initWithString:[NSString stringWithFormat:@"%lu", (long)SHOW_TIME_24_NUMBER_OF_HOURS]
                                           attributes:@{NSFontAttributeName : self.displayFont}];
    CGFloat sampleAttStringWidth = sampleAttString.size.width;
    
    return sampleAttStringWidth + (sampleAttStringWidth * PICKERVIEW_SIZING_HORIZONTAL_PADDING_FACTOR);
}

-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view {
    UILabel *returnLabel = [[UILabel alloc] initWithFrame:view.frame];
    
    NSString *unformattedLabelString = nil;
    if (component == PICKERVIEW_HOURS_COMPONENT_INDEX)
    {
        if (!self.showTimeIn24HourFormat && row == 0)
        {
            unformattedLabelString = [NSString stringWithFormat:@"%u", 12];
        }
        else
        {
            unformattedLabelString = [NSString stringWithFormat:@"%lu", (long)row];
        }
    }
    else if (component == PICKERVIEW_MINUTES_COMPONENT_INDEX)
    {
        if (row < 10)
        {
            unformattedLabelString = [NSString stringWithFormat:@"%u", 0];
            unformattedLabelString = [unformattedLabelString stringByAppendingString:[NSString stringWithFormat:@"%lu", (long)row]];
        }
        else
        {
            unformattedLabelString = [NSString stringWithFormat:@"%lu", (long)row];
        }
    }
    else if (component == PICKERVIEW_PERIOD_COMPONENT_INDEX)
    {
        unformattedLabelString = row == 0 ? PERIOD_AT_INDEX_0_STRING : PERIOD_AT_INDEX_1_STRING;
    }
    NSDictionary *attStringDictionary = @{NSFontAttributeName : self.displayFont,
                                          NSForegroundColorAttributeName : self.fontColor};
    
    [returnLabel setAttributedText:[[NSAttributedString alloc] initWithString:unformattedLabelString attributes:attStringDictionary]];
    returnLabel.textAlignment = NSTextAlignmentCenter;
    
    return returnLabel;
}

-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component {
    NSInteger currHoursSelected = [self selectedRowInComponent:PICKERVIEW_HOURS_COMPONENT_INDEX];
    NSString *currHoursString = nil;
    NSInteger currMinutesSelected = [self selectedRowInComponent:PICKERVIEW_MINUTES_COMPONENT_INDEX];
    NSString *currMinutesString = nil;
    
    if (currHoursSelected < 10)
    {
        currHoursString = [NSString stringWithFormat:@"%u%lu", 0, (long)currHoursSelected];
    }
    else
    {
        currHoursString = [NSString stringWithFormat:@"%lu", (long)currHoursSelected];
    }
    
    if (currMinutesSelected < 10)
    {
        currMinutesString = [NSString stringWithFormat:@"%u%lu", 0, (long)currMinutesSelected];
    }
    else
    {
        currMinutesString = [NSString stringWithFormat:@"%lu", (long)currMinutesSelected];
    }
    
    NSString *currPeriodString = nil;
    if (!self.showTimeIn24HourFormat)
    {
        currPeriodString = [self selectedRowInComponent:PICKERVIEW_PERIOD_COMPONENT_INDEX] == 0 ?
        PERIOD_AT_INDEX_0_STRING : PERIOD_AT_INDEX_1_STRING;
    }
    
    
    NSString *dateAsString = [NSString stringWithFormat:@"%@:%@%@",
                              currHoursString, currMinutesString, (currPeriodString ?
                                                                   [@":" stringByAppendingString:currPeriodString] : @"")];
    
    self.currSelectedTime = [self.dateFormatter dateFromString:dateAsString];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLOUNDS_DATE_PICKER_VALUE_CHANGED_NOTIFICATION
                                                        object:self];
    
}

@end
