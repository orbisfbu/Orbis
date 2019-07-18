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

@interface MasterViewController ()
@property (strong, nonatomic) CreateEventViewController *createEventController;
@property (strong, nonatomic) ExploreViewController *exploreController;
@property (strong, nonatomic) UserViewController *userController;
@property (weak, nonatomic) IBOutlet UIScrollView *viewControllerScrollView;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set up the scroll view with nested view controllers
    [self initializeHorizontalSwiping];
}

- (void)initializeHorizontalSwiping {
    // Initiate instances of view controllers of class View1 and View2
    self.createEventController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil];
    self.exploreController = [[ExploreViewController alloc] initWithNibName:@"ExploreViewController" bundle:nil];
    self.userController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
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
- (IBAction)createNewEventButtonPressed:(id)sender {
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.createEventController.view.frame.origin.x, self.createEventController.view.frame.origin.y) animated:YES];
}

- (IBAction)exploreButtonPressed:(id)sender {
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.exploreController.view.frame.origin.x, self.exploreController.view.frame.origin.y) animated:YES];
}

- (IBAction)profileButtonPressed:(id)sender {
    [self.viewControllerScrollView setContentOffset:CGPointMake(self.userController.view.frame.origin.x, self.userController.view.frame.origin.y) animated:YES];
}

@end
