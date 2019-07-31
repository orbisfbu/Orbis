//
//  LocationCell.h
//  Pitch
//
//  Created by ezietz on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKLocalSearchRequest.h>
#import <MapKit/MKLocalSearch.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISearchBar *locationCellSearchBar;
@property (strong, nonatomic) UITableView *createLocationDropDownTableView;

@end

NS_ASSUME_NONNULL_END
