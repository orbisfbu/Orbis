//
//  ChoosePhotoViewController.h
//  Pitch
//
//  Created by mariobaxter on 8/7/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ChoosePhotoViewControllerDelegate <NSObject>
- (void)sendImageBack:(UIImage *)image;
@end

@interface ChoosePhotoViewController : UIViewController
@property (nonatomic, weak) id<ChoosePhotoViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END

