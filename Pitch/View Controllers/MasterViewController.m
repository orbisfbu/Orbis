//
//  ViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "MasterViewController.h"
#import "CreateEventViewController.h"
#import "ExploreViewController.h"
#import "UserViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static double const MAX_ICON_HEIGHT_AND_WIDTH = 55;
static double const MIN_ICON_HEIGHT_AND_WIDTH = 40;

static double const MAX_ICON_Y_OFFSET = 40;
static double const MIN_ICON_Y_OFFSET = 30;

static double const MAX_ICON_X_OFFSET = 60;
static double const MIN_ICON_X_OFFSET = 30;


@interface MasterViewController () <UIScrollViewDelegate, DismissViewControllerDelegate>
@property (strong, nonatomic) CreateEventViewController *createEventController;
@property (strong, nonatomic) ExploreViewController *exploreController;
@property (strong, nonatomic) UserViewController *userController;
@property (strong, nonatomic) IBOutlet UIScrollView *viewControllerScrollView;
@property (strong, nonatomic) UIButton *createEventButton;
@property (strong, nonatomic) UIButton *exploreButton;
@property (strong, nonatomic) UIButton *profileButton;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.createEventButton = [[UIButton alloc] initWithFrame: CGRectMake(MAX_ICON_X_OFFSET, self.view.frame.size.height - MIN_ICON_HEIGHT_AND_WIDTH - MIN_ICON_Y_OFFSET, MIN_ICON_HEIGHT_AND_WIDTH, MIN_ICON_HEIGHT_AND_WIDTH)];
    [self.createEventButton setImage:[UIImage imageNamed:@"event"] forState:UIControlStateNormal];
    [self.createEventButton addTarget:self action:@selector(createNewEventButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.createEventButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.createEventButton.layer.cornerRadius = 10;
    [self.createEventButton setBackgroundColor:[UIColor colorWithRed:0.5 green:0.8 blue:0.7 alpha:0.5]];
    [self.view addSubview:self.createEventButton];
    
    self.exploreButton = [[UIButton alloc] initWithFrame: CGRectMake((self.view.frame.size.width-MAX_ICON_HEIGHT_AND_WIDTH)/2, self.view.frame.size.height - MAX_ICON_HEIGHT_AND_WIDTH - MAX_ICON_Y_OFFSET, MAX_ICON_HEIGHT_AND_WIDTH, MAX_ICON_HEIGHT_AND_WIDTH)];
    [self.exploreButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.exploreButton addTarget:self action:@selector(exploreButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.exploreButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.exploreButton.layer.cornerRadius = 10;
    [self.exploreButton setBackgroundColor:[UIColor colorWithRed:0.5 green:0.8 blue:0.7 alpha:0.5]];
    [self.view addSubview:self.exploreButton];
    
    self.profileButton = [[UIButton alloc] initWithFrame: CGRectMake(self.view.frame.size.width - MIN_ICON_HEIGHT_AND_WIDTH - MAX_ICON_X_OFFSET, self.view.frame.size.height - MIN_ICON_HEIGHT_AND_WIDTH - MIN_ICON_Y_OFFSET, MIN_ICON_HEIGHT_AND_WIDTH, MIN_ICON_HEIGHT_AND_WIDTH)];
    [self.profileButton setImage:[UIImage imageNamed:@"user"] forState:UIControlStateNormal];
    [self.profileButton addTarget:self action:@selector(profileButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.profileButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.profileButton.layer.cornerRadius = 10;
    [self.profileButton setBackgroundColor:[UIColor colorWithRed:0.5 green:0.8 blue:0.7 alpha:0.5]];
    [self.view addSubview:self.profileButton];
    
    // Set up the scroll view with nested view controllers
    self.viewControllerScrollView.delegate = self;
    [self initializeHorizontalSwiping];
}

- (void)initializeHorizontalSwiping {
    // Initiate instances of view controllers of class View1 and View2
    self.createEventController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil];
    self.exploreController = [[ExploreViewController alloc] initWithNibName:@"ExploreViewController" bundle:nil];
    self.userController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
    self.userController.delegate = self;
    // Add child view controllers
    [self addChildViewController:self.createEventController];
    [self addChildViewController:self.exploreController];
    [self addChildViewController:self.userController];
    // Add the view controller views to the scroll view
    [self.viewControllerScrollView addSubview:self.createEventController.view];
    [self.viewControllerScrollView addSubview:self.exploreController.view];
    [self.viewControllerScrollView addSubview:self.userController.view];
    [self.createEventController didMoveToParentViewController:self];
    [self.exploreController didMoveToParentViewController:self];
    [self.userController didMoveToParentViewController:self];
    
    // Offset the user viewController to the right :)
    CGRect userFrame = self.userController.view.frame;
    userFrame.origin.x = 2*self.view.frame.size.width;
    self.userController.view.frame = userFrame;
    // Offset the events viewController to the left :)
    CGRect exploreFrame = self.exploreController.view.frame;
    exploreFrame.origin.x = self.view.frame.size.width;
    self.exploreController.view.frame = exploreFrame;
    // Resize the scroll view to be able to encompass all the view controllers
    self.viewControllerScrollView.contentSize = CGSizeMake(self.view.frame.size.width*3, self.view.frame.size.height);
    
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.exploreController.view.frame.origin.x, self.exploreController.view.frame.origin.y) animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    double xPos = scrollView.contentOffset.x;
    if (xPos < self.view.frame.size.width) {
        int createWidth = MAX_ICON_HEIGHT_AND_WIDTH - xPos*(MAX_ICON_HEIGHT_AND_WIDTH - MIN_ICON_HEIGHT_AND_WIDTH)/self.view.frame.size.width;
        int createX = MIN_ICON_X_OFFSET + xPos*(MAX_ICON_X_OFFSET - MIN_ICON_X_OFFSET)/self.view.frame.size.width;
        int createY = self.view.frame.size.height - createWidth - (MAX_ICON_Y_OFFSET - xPos*(MAX_ICON_Y_OFFSET - MIN_ICON_Y_OFFSET)/self.view.frame.size.width);
        self.createEventButton.frame = CGRectMake(createX, createY, createWidth, createWidth);
        int exploreWidth = MIN_ICON_HEIGHT_AND_WIDTH + xPos*(MAX_ICON_HEIGHT_AND_WIDTH - MIN_ICON_HEIGHT_AND_WIDTH)/self.view.frame.size.width;;
        int exploreX = (self.view.frame.size.width-exploreWidth)/2;
        int exploreY = self.view.frame.size.height - exploreWidth - (MIN_ICON_Y_OFFSET + xPos*(MAX_ICON_Y_OFFSET - MIN_ICON_Y_OFFSET)/self.view.frame.size.width);
        self.exploreButton.frame = CGRectMake(exploreX, exploreY, exploreWidth, exploreWidth);
    } else {
        int exploreWidth = MAX_ICON_HEIGHT_AND_WIDTH - (xPos-self.view.frame.size.width)*(MAX_ICON_HEIGHT_AND_WIDTH - MIN_ICON_HEIGHT_AND_WIDTH)/self.view.frame.size.width;
        int exploreY = self.view.frame.size.height - exploreWidth - (MAX_ICON_Y_OFFSET - (xPos-self.view.frame.size.width)*(MAX_ICON_Y_OFFSET - MIN_ICON_Y_OFFSET)/self.view.frame.size.width);
        int exploreX = (self.view.frame.size.width-exploreWidth)/2;
        self.exploreButton.frame = CGRectMake(exploreX, exploreY, exploreWidth, exploreWidth);
        int profileWidth = MIN_ICON_HEIGHT_AND_WIDTH + (xPos-self.view.frame.size.width)*(MAX_ICON_HEIGHT_AND_WIDTH - MIN_ICON_HEIGHT_AND_WIDTH)/self.view.frame.size.width;
        int profileX = self.view.frame.size.width - profileWidth - (MAX_ICON_X_OFFSET - (xPos-self.view.frame.size.width)*(MAX_ICON_X_OFFSET - MIN_ICON_X_OFFSET)/self.view.frame.size.width);
        int profileY = self.view.frame.size.height - profileWidth - (MIN_ICON_Y_OFFSET + (xPos-self.view.frame.size.width)*(MAX_ICON_Y_OFFSET - MIN_ICON_Y_OFFSET)/self.view.frame.size.width);
        self.profileButton.frame = CGRectMake(profileX, profileY, profileWidth, profileWidth);
    }
}

- (void) createNewEventButtonPressed {
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.createEventController.view.frame.origin.x, self.createEventController.view.frame.origin.y) animated:YES];
}

- (void) exploreButtonPressed {
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.exploreController.view.frame.origin.x, self.exploreController.view.frame.origin.y) animated:YES];
}

- (void) profileButtonPressed {
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.userController.view.frame.origin.x, self.userController.view.frame.origin.y) animated:YES];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate showLoginScreen];
    }];
}

@end
