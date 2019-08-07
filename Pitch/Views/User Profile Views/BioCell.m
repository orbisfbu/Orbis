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
        //self.bioTextView.text = @"Add a bio here...";
        //self.bioTextView.editable = NO;
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

//- (void)textViewDidChange:(UITextView *)textView
//{
//    self.bioTextView.scrollEnabled = NO;
//    CGSize sizeThatShouldFitTheContent = [self.bioTextView sizeThatFits:self.bioTextView.frame.size];
//    self.heightConstraint.constant = sizeThatShouldFitTheContent.height;
//    
////    CGFloat fixedWidth = textView.frame.size.width;
////    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
////    CGRect newFrame = textView.frame;
////    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
////    textView.frame = newFrame;
//}

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
            //[self.editUserBioButton addTarget:self action:@selector(editBio) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            NSLog(@"Can't update bio");
        }
    }];
    //[self.editUserBioButton setTitle:@"Edit" forState:UIControlStateNormal];
    //[self.bioTextView setText:[UserInSession shared].sharedUser.userBioString];
 //   self.bioTextView.editable = NO;

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
