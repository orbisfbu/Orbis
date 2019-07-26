//
//  UserViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UserViewController.h"
#import "LogInViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@import UIKit;
@import Firebase;
@import FirebaseAuth;

// Constant max and min heights of profile background image view
static double const BACKGORUND_IMAGE_MIN_HEIGHT = 50.0;
static double const BACKGORUND_IMAGE_MAX_HEIGHT = 250.0;

@interface UserViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, LoginViewControllerDelegate>

//this is the user object to load once user gets to profile view
@property (strong, nonatomic) User *userToLoad;
//inputted properties to be used and checked during
//the welcoming process; will have to check whether or not
//initially inputted email and password correspond to existing account
@property (weak, nonatomic) NSString *inputtedUserEmail;
@property (weak, nonatomic) NSString *inputtedPassword;
//these registering properties are to be set if inputted email doesn't
//correspond to an account
@property (weak, nonatomic) NSString *registerFirstName;
@property (weak, nonatomic) NSString *registerLastName;
@property (weak, nonatomic) NSString *registerUsername;
//for the password confirm field later on, just make sure that
//the text of that cofirm password field is the same registerPassword
@property (weak, nonatomic) NSString *registerPassword;

// For continue screen
@property (strong, nonatomic) UILabel *welcomeLabel1;
@property (strong, nonatomic) UILabel *welcomeLabel2;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UILabel *orLabel;

// For login screen
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *logInButton;

// For signup screen 1
@property (strong, nonatomic) UITextField *firstNameTextField;
@property (strong, nonatomic) UITextField *lastNameTextField;
@property (strong, nonatomic) UIButton *nextButton;

// For signup screen 2
@property (strong, nonatomic) UITextField *usernameSignUpTextField;
@property (strong, nonatomic) UITextField *passwordSignUpTextField;
@property (strong, nonatomic) UITextField *confirmPasswordSignUpTextField;
@property (strong, nonatomic) UIButton *signUpButton;

// For user profile screen
@property (strong, nonatomic) UIImageView *userBackgroundImageView;
@property (strong, nonatomic) UIImageView *userProfileImageView;
@property (strong, nonatomic) UITableView *userProfileTableView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIButton *editProfileButton;

@end


@implementation UserViewController

//load correct user info
- (void)userWasCreated:(nonnull User *)createdUser {
    self.userToLoad = createdUser;
}

- (void)viewDidLoad {
    //user currentAccessToken to detect whether a Facebook user
    //is already logged-in; if so, automatically load the profile
    //and profile picture when userView is selected
    [super viewDidLoad];
    [self createPageObjects];
    [self createUserProfile];
}

- (void) createPageObjects {
    // Add user background photo
    self.userBackgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200)];
    [self.userBackgroundImageView setImage:[UIImage imageNamed:@"default_background"]];
    [self.userBackgroundImageView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.userBackgroundImageView];
    
    // Add profile scroll view
    self.userProfileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.userBackgroundImageView.frame.size.height) style:UITableViewStylePlain];
    self.userProfileTableView.delegate = self;
    self.userProfileTableView.dataSource = self;
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"VibesCell" bundle:nil] forCellReuseIdentifier:@"VibesCell"];
    [self.view addSubview:self.userProfileTableView];
    
    // Add user profile photo
    self.userProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width/3, self.view.frame.size.width/3)];
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width/2;
    [self.userProfileImageView setImage:[UIImage imageNamed:@"default_profile"]];
    [self.userProfileImageView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.userProfileImageView];
    
    // Add username label
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height, 100, 20)];
    [self.usernameLabel setFont:[UIFont fontWithName:@"roboto" size:20]];
    [self.usernameLabel setClipsToBounds:YES];
    self.usernameLabel.layer.cornerRadius = 5;
    [self.usernameLabel setText:@" @user_name "];
    
    if ([FIRAuth auth].currentUser)
    {
        NSLog(@"USER NAME LABEL SHOULD CHANGE");
        //self.usernameLabel.text = [FIRAuth auth].currentUser.displayName;
    }
    [self.usernameLabel sizeToFit];
    [self.usernameLabel setCenter:CGPointMake(self.view.center.x, self.usernameLabel.center.y)];
    [self.usernameLabel setBackgroundColor:UIColorFromRGB(0x157f5f)];
    [self.view addSubview:self.usernameLabel];
    
    // Add edit profile button
    self.editProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 30, self.view.frame.size.height, 30, 30)];
    [self.editProfileButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [self.editProfileButton setBackgroundColor:UIColorFromRGB(0x157f5f)];
    self.editProfileButton.layer.cornerRadius = 5;
    [self.editProfileButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.editProfileButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editProfileButton];
}

- (void) createUserProfile {
    [UIView animateWithDuration:0.5 animations:^{
        self.userBackgroundImageView.frame = CGRectMake(self.userBackgroundImageView.frame.origin.x, 0, self.userBackgroundImageView.frame.size.width, self.userBackgroundImageView.frame.size.height);
        self.userProfileImageView.frame = CGRectMake(self.userProfileImageView.frame.origin.x, self.userBackgroundImageView.frame.size.height/3, self.userProfileImageView.frame.size.width, self.userProfileImageView.frame.size.height);
        self.userProfileTableView.frame = CGRectMake(self.userProfileTableView.frame.origin.x, self.userBackgroundImageView.frame.size.height, self.userProfileTableView.frame.size.width, self.userProfileTableView.frame.size.height);
        self.usernameLabel.frame = CGRectMake(self.usernameLabel.frame.origin.x, 15, self.usernameLabel.frame.size.width, self.usernameLabel.frame.size.height);
        self.editProfileButton.frame = CGRectMake(self.editProfileButton.frame.origin.x, 15, self.editProfileButton.frame.size.width, self.editProfileButton.frame.size.height);
    }];
}

- (void) dismissUserProfile {
    // Resize everything to original size, not the size it is modified to after scrolling
}

- (void) editButtonPressed {
    
    NSLog(@"LOGOUT BUTTON WAS PRESSED");
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }else{
        NSLog(@"Successfully Signout");
        NSLog(@"IS THE USER STILL IN SESSION? %@", [FIRAuth auth].currentUser);
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
    }
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"VibesCell"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int delta = scrollView.contentOffset.y;
    
    if (self.userBackgroundImageView.frame.size.height - delta < BACKGORUND_IMAGE_MIN_HEIGHT) {
        self.userBackgroundImageView.frame = CGRectMake(self.userBackgroundImageView.frame.origin.x, self.userBackgroundImageView.frame.origin.y, self.userBackgroundImageView.frame.size.width, BACKGORUND_IMAGE_MIN_HEIGHT);
        self.userProfileTableView.frame = CGRectMake(self.userProfileTableView.frame.origin.x, BACKGORUND_IMAGE_MIN_HEIGHT, self.userProfileTableView.frame.size.width, self.view.frame.size.height - BACKGORUND_IMAGE_MIN_HEIGHT);
    } else if (self.userBackgroundImageView.frame.size.height - delta > BACKGORUND_IMAGE_MAX_HEIGHT) {
        self.userBackgroundImageView.frame = CGRectMake(self.userBackgroundImageView.frame.origin.x, self.userBackgroundImageView.frame.origin.y, self.userBackgroundImageView.frame.size.width, BACKGORUND_IMAGE_MAX_HEIGHT);
        self.userProfileTableView.frame = CGRectMake(self.userProfileTableView.frame.origin.x, BACKGORUND_IMAGE_MAX_HEIGHT, self.userProfileTableView.frame.size.width, self.view.frame.size.height - BACKGORUND_IMAGE_MAX_HEIGHT);
    } else {
        NSLog(@"%i", delta);
        // Reframe the background image
        self.userBackgroundImageView.frame = CGRectMake(0, 0, self.userBackgroundImageView.frame.size.width, self.userBackgroundImageView.frame.size.height-delta);
        self.userProfileTableView.frame = CGRectMake(0, self.userBackgroundImageView.frame.size.height-delta, self.userBackgroundImageView.frame.size.width, self.view.frame.size.height - self.userBackgroundImageView.frame.size.height);
        // Reframe the profile image
        self.userProfileImageView.frame = CGRectMake(self.userProfileImageView.frame.origin.x, self.userProfileImageView.frame.origin.y - 0.45*delta, self.userProfileImageView.frame.size.width - 0.45*delta, self.userProfileImageView.frame.size.height - 0.45*delta);
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width/2;
        [self.userProfileTableView setContentOffset: CGPointMake(self.userProfileTableView.contentOffset.x, 0)];
    }
    float heightOfBackgroundImage = self.userBackgroundImageView.frame.size.height;
    if (heightOfBackgroundImage > BACKGORUND_IMAGE_MIN_HEIGHT && heightOfBackgroundImage < 200) {
        [self.userBackgroundImageView setAlpha:(heightOfBackgroundImage-BACKGORUND_IMAGE_MIN_HEIGHT + 20)/100];
    }
}


@end
