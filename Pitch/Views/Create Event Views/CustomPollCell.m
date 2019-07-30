//
//  CustomPollCell.m
//  Pitch
//
//  Created by ezietz on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "CustomPollCell.h"

@interface CustomPollCell () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation CustomPollCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    <#code#>
//}
//
//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    <#code#>
//}

@end
