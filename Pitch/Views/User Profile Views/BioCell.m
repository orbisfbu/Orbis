//
//  BioCell.m
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "BioCell.h"
#import "UserInSession.h"

@implementation BioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.bioTextView setText:[UserInSession shared].sharedUser.userBioString];
    //    self.userBioTextView.text = [NSString stringWithFormat: @"This is what a user bio would look like!"];
    //self.userBioLabel.text = @"Tap the edit button to add a bio!";
    if (self.bioTextView.text && self.bioTextView.text.length > 0) {
        /* not empty - do something */
        self.bioTextView.editable = NO;
        //[self.bioTextView setText:[UserInSession shared].sharedUser.userBioString];
    }
    else {
        self.bioTextView.text = @"Add a bio here...";
        self.bioTextView.editable = NO;
    }
    [self.editUserBioButton addTarget:self action:@selector(editBio) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.bioTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.bioTextView resignFirstResponder];
}

- (void) editBio {
    self.bioTextView.editable = YES;
    if ([self.bioTextView.text isEqualToString:(@"")]){
        self.bioTextView.text = @"Add a bio here...";
    }
    [self.editUserBioButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.editUserBioButton addTarget:self action:@selector(saveBioChanges) forControlEvents:UIControlEventTouchUpInside];

}

- (void) saveBioChanges{
    [self.editUserBioButton setTitle:@"Edit" forState:UIControlStateNormal];
    //[self.bioTextView setText:[UserInSession shared].sharedUser.userBioString];
    self.bioTextView.editable = NO;
    [self.editUserBioButton addTarget:self action:@selector(editBio) forControlEvents:UIControlEventTouchUpInside];
}
//    if ([self.userBioLabel.text isEqualToString:@""]) {
//        self.userBioLabel.text = @"Write your own bio...";
//        self.userBioLabel.textColor = [UIColor blackColor];
//    }
////    self.userBioLabel.layer.cornerRadius = 5;
////    self.userBioLabel.layer.borderWidth = 0.6f;
////    self.userBioTextView.delegate = self;
//
//    UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
//    [keyboardToolbar sizeToFit];
//    UIView *bioFieldView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 150))];
//    self.userBioTextView.inputAccessoryView = keyboardToolbar;


//- (void) textViewDidBeginEditing:(UITextView *) textView{
//    if ([self.userBioTextView.text isEqualToString:@"Write your own bio...."]) {
//        self.userBioTextView.text = @"";
//    }
//    [self.userBioTextView becomeFirstResponder];
//}
//
//- (void) textViewDidEndEditing:(UITextView *) textView{
//    if ([self.userBioTextView.text isEqualToString:@""]) {
//        self.userBioTextView.text = @"Write your own bio...";
//    }
//    [self.userBioTextView resignFirstResponder];
//}
//


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
