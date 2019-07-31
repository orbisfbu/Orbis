//
//  LocationCell.m
//  Pitch
//
//  Created by ezietz on 7/22/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "LocationCell.h"
#import "CreateEventViewController.h"
#import "EventTitleCell.h"
#import "VibesCell.h"
#import "PollsTitleCell.h"
#import <MapKit/MapKit.h>

@interface LocationCell () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MKLocalSearchCompleterDelegate>
@property (nonatomic, readonly) NSArray<MKMapItem *> *mapItems;
@property (nonatomic, strong) MKLocalSearch *search;

@end

@implementation LocationCell
int cont = 0;
- (void)awakeFromNib {
    [super awakeFromNib];
    [self makeCreateLocationDropDownTableView];
    self.locationCellSearchBar.delegate = self;
}

- (void) makeCreateLocationDropDownTableView {
    CGRect frame = CGRectMake(self.locationCellSearchBar.frame.origin.x + 15, self.locationCellSearchBar.frame.origin.y + self.locationCellSearchBar.frame.size.height - 90, self.locationCellSearchBar.frame.size.width + 15, self.createLocationDropDownTableView.contentSize.height); // last was 0// TESTING
//     CGRect frame = CGRectMake(self.locationCellSearchBar.frame.origin.x + 15, self.locationCellSearchBar.frame.origin.y + self.locationCellSearchBar.frame.size.height, self.locationCellSearchBar.frame.size.width - 30, self.createLocationDropDownTableView.contentSize.height); // original
    self.createLocationDropDownTableView = [[UITableView alloc] initWithFrame:frame];
    self.createLocationDropDownTableView.layer.cornerRadius = 10;
    [self.createLocationDropDownTableView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.createLocationDropDownTableView];
    self.createLocationDropDownTableView.delegate = self;
    self.createLocationDropDownTableView.dataSource = self;
    [self.createLocationDropDownTableView setAllowsSelection:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![self.locationCellSearchBar.text isEqualToString:@""]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // run tasks in the background/background thread
            [NSThread sleepForTimeInterval:3.0f];
            dispatch_async(dispatch_get_main_queue(), ^{ // run UI updates
                [self searchDidFire];
                cont++;
                NSLog(@"%i",cont);
            });
        });
        [self.search cancel];
        self.search = nil;
        [UIView animateWithDuration:0.2 animations:^{
            self.createLocationDropDownTableView.frame = CGRectMake(self.createLocationDropDownTableView.frame.origin.x, self.createLocationDropDownTableView.frame.origin.y, self.createLocationDropDownTableView.frame.size.width, 0); // last was 175
        }];
    }
    else {
        [self.search cancel];
        self.search = nil;
        [UIView animateWithDuration:0.2 animations:^{
            self.createLocationDropDownTableView.frame = CGRectMake(self.createLocationDropDownTableView.frame.origin.x, self.createLocationDropDownTableView.frame.origin.y, self.createLocationDropDownTableView.frame.size.width, 0);
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (![self.locationCellSearchBar.text isEqualToString:@""]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.createLocationDropDownTableView.frame = CGRectMake(self.createLocationDropDownTableView.frame.origin.x, self.createLocationDropDownTableView.frame.origin.y, self.createLocationDropDownTableView.frame.size.width, self.createLocationDropDownTableView.contentSize.height); // last was 175
        }];
    }
    [self.search cancel];
    self.search = nil;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.search cancel];
    self.search = nil;
    self.locationCellSearchBar.showsCancelButton = NO;
    self.locationCellSearchBar.text = @"";
    [self.locationCellSearchBar resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.createLocationDropDownTableView.frame = CGRectMake(self.createLocationDropDownTableView.frame.origin.x,self.createLocationDropDownTableView.frame.origin.y, 0, 0); }];
}

- (void)searchDidFire {
    MKLocalSearchRequest *req = [[MKLocalSearchRequest alloc] init];
    if (self.locationCellSearchBar.text != 0) {
        NSString *substring = [NSString stringWithString:self.locationCellSearchBar.text];
        [req setNaturalLanguageQuery:substring];
        self.search = [[MKLocalSearch alloc] initWithRequest:req];
        [self.search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
            self->_mapItems = response.mapItems;
            [self->_createLocationDropDownTableView reloadData];
        }];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    //[cell awakeFromNib];
    cell.textLabel.text = _mapItems[indexPath.row].placemark.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.search cancel];
    self.search = nil;
    UITableViewCell *selectedCell = [self.createLocationDropDownTableView cellForRowAtIndexPath:indexPath];
    self.locationCellSearchBar.text = selectedCell.textLabel.text;
    [UIView animateWithDuration:0.2 animations:^{
        self.createLocationDropDownTableView.frame = CGRectMake(self.createLocationDropDownTableView.frame.origin.x,self.createLocationDropDownTableView.frame.origin.y, self.createLocationDropDownTableView.frame.size.width, 0); }]; // last was 0
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [UIView animateWithDuration:0.2 animations:^{
        self.createLocationDropDownTableView.frame = CGRectMake(self.createLocationDropDownTableView.frame.origin.x,self.createLocationDropDownTableView.frame.origin.y, self.createLocationDropDownTableView.frame.size.width, self.createLocationDropDownTableView.contentSize.height); }]; // last coordinate waspreviously 0
    if ([self.mapItems count] > 4){
        return 4;
    }
    return [_mapItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
