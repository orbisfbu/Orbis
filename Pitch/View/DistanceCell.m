//
//  DistanceCell.m
//  Pitch
//
//  Created by mariobaxter on 7/19/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "DistanceCell.h"

@implementation DistanceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dataArray = @[@"Less than ", @"Greater than "];
    // Initialization code
    self.menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(15, 30) andHeight:20];
    //DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithFrame:CGRectMake(self.frame.origin.x + 10, self.distanceLabel.frame.origin.y + 10, 100, 20)];
    self.menu.delegate = self;
    self.menu.dataSource = self;
    [self.contentView addSubview: self.menu];
    [self.menu selectIndexPath:[DOPIndexPath indexPathWithCol:0 row:0 item:0]];
    
//    NSLayoutConstraint *bottom =[NSLayoutConstraint constraintWithItem:self.menu attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
//    NSLayoutConstraint *left =[NSLayoutConstraint constraintWithItem:self.menu attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
//    NSLayoutConstraint *top =[NSLayoutConstraint constraintWithItem:self.menu attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.distanceLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
//    NSLayoutConstraint *right =[NSLayoutConstraint constraintWithItem:self.menu attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:10];
//    [self.contentView addConstraints:@[top, right, left, bottom]];
    //self.distancePickerView.delegate = self;
    //self.distancePickerView.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    return 2;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSLog(@"HERE BOIIIIIII");
    return self.dataArray[indexPath.item];
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSLog(@"HERE BOIIIIIII");
    return self.dataArray[indexPath.row];
}

@end
