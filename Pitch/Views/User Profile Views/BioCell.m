//
//  BioCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "BioCell.h"
#import "UserInSession.h"
#import "DataHandling.h"

// Colors
static NSInteger const LABEL_GREEN = 0x0d523d;
static NSInteger const LABEL_GRAY = 0xc7c7cd;
static NSInteger const DARK_GREEN = 0x157f5f;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define MAXLENGTH 23

@implementation BioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.charsLeftInBioLabel setText:[NSString stringWithFormat:@"(%d)", MAXLENGTH]];
    [self.charsLeftInBioLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:17]];
    self.charsLeftInBioLabel.textColor = UIColorFromRGB(LABEL_GRAY);
    [self.bioTextView setText:[UserInSession shared].sharedUser.userBioString];
    self.charsLeftInBioLabel.alpha = 0;
    self.bioTextView.delegate = self;
    if (self.bioTextView.text && self.bioTextView.text.length > 0) {
        self.bioTextView.editable = NO;
    }
    else {
        //self.bioTextView.text = @"Add a bio here...";
        //self.bioTextView.editable = NO;
    }
    [self.editUserBioButton addTarget:self action:@selector(editBio) forControlEvents:UIControlEventTouchUpInside];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.charsLeftInBioLabel.alpha = 1;
    [self.bioTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.charsLeftInBioLabel.alpha = 0;
    [self.bioTextView resignFirstResponder];
}

- (void) textViewDidChange:(UITextView *)textView {
    self.charsLeftInBioLabel.alpha = 1;
    [self.charsLeftInBioLabel setText:[NSString stringWithFormat:@"(%lu)", MAXLENGTH - self.bioTextView.text.length]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAXLENGTH || returnKey;
}

- (void) editBio {
    self.bioTextView.editable = YES;
    [self.bioTextView becomeFirstResponder];
    if ([self.bioTextView.text isEqualToString:(@"")]){
       // self.bioTextView.text = @"Add a bio here...";
    }
    [self.editUserBioButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.editUserBioButton addTarget:self action:@selector(saveBioChanges) forControlEvents:UIControlEventTouchUpInside];

}

- (void) saveBioChanges{
    [self.editUserBioButton setTitle:@"Edit" forState:UIControlStateNormal];
    self.bioTextView.editable = NO;
    [self.editUserBioButton addTarget:self action:@selector(editBio) forControlEvents:UIControlEventTouchUpInside];
    [[DataHandling shared] updateUserBio:self.bioTextView.text withCompletion:^(BOOL succeeded) {
        if (succeeded) {
            NSLog(@"Saved bio");
        }
        else {
            NSLog(@"Can't update bio");
        }
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
