//
//  LogoutCell.h
//  Pitch
//
//  Created by mariobaxter on 7/26/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LogoutUserDelegate
- (void) logoutUser;
@end

@interface LogoutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, weak) id<LogoutUserDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
