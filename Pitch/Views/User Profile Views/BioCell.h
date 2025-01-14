//
//  BioCell.h
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BioCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *editUserBioButton;
@property (strong, nonatomic) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) IBOutlet UILabel *charsLeftInBioLabel;

@end

NS_ASSUME_NONNULL_END
