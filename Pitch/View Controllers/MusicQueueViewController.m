//
//  MusicQueueViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/31/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MusicQueueViewController.h"
#import "MusicQueueTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MusicQueueViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray <NSMutableDictionary *> *musicQueue;
@end

@implementation MusicQueueViewController

- (void)viewDidLoad {
    [self configureInitialViewsAndGestures];
    self.musicQueue = self.event.musicQueue;
}

- (void)configureInitialViewsAndGestures {
    [super viewDidLoad];
    self.titleView.layer.cornerRadius = 30;
    self.titleView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    self.swipeIndicatorView.layer.cornerRadius = self.swipeIndicatorView.frame.size.height/2;
    [self.swipeIndicatorView setBackgroundColor:[UIColor lightGrayColor]];
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [self.clickableMapView addGestureRecognizer:tapMap];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.titleView addGestureRecognizer: downGestureRecognizer];
    
    [self.addSongButton setAlpha:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MusicQueueTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicQueueTableViewCell"];
}

- (void)dismissTabBarModal:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addSongButtonPressed:(id)sender {
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (!self.isRegistered && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.textLabel setText:@"Register to Edit Queue"];
        [cell.textLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:17]];
        [cell.textLabel setTextColor:UIColorFromRGB(0xf45532)];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        return cell;
    } else if (!self.isRegistered) {
        MusicQueueTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MusicQueueTableViewCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        [cell.songNameLabel setText:self.musicQueue[indexPath.row - 1][@"Title"]];
        [cell.artistNameLabel setText:self.musicQueue[indexPath.row - 1][@"Artist Name"]];
        return cell;
    } else {
        MusicQueueTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MusicQueueTableViewCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        [cell.songNameLabel setText:self.musicQueue[indexPath.row][@"Title"]];
        [cell.artistNameLabel setText:self.musicQueue[indexPath.row][@"Artist Name"]];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicQueue.count + 1;
}

@end
