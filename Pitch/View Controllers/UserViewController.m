//
//  UserViewController.m
//  Pitch
//
//  Created by mariobaxter on 7/17/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UserViewController.h"
#import "BioCell.h"
#import "ProfileLinksCell.h"
#import "EventListCell.h"
#import "FirstLastNameCell.h"
#import "LogInViewController.h"
#import "LogoutCell.h"
#import "UserInSession.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@import UIKit;
@import Firebase;
@import FirebaseAuth;

// Constant max and min heights of profile background image view
static double const BACKGORUND_IMAGE_MIN_HEIGHT = 70.0;
static double const BACKGORUND_IMAGE_MAX_HEIGHT = 250.0;

@interface UserViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, LogoutUserDelegate>

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
    [self.view addSubview:self.userBackgroundImageView];
    [self.userBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.userBackgroundImageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.userBackgroundImageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[self.userBackgroundImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.userBackgroundImageView.heightAnchor constraintEqualToConstant:200] setActive:YES];
    [self.userBackgroundImageView setImage:[UIImage imageNamed:@"background_user_default"]];
    [self.userBackgroundImageView setBackgroundColor:[UIColor blueColor]];
    
    // Add profile scroll view
    self.userProfileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.userBackgroundImageView.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.userProfileTableView];
    [self.userProfileTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.userProfileTableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.userProfileTableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[self.userProfileTableView.topAnchor constraintEqualToAnchor:self.userBackgroundImageView.bottomAnchor] setActive:YES];
    [[self.userProfileTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"BioCell" bundle:nil] forCellReuseIdentifier:@"BioCell"];
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"ProfileLinksCell" bundle:nil] forCellReuseIdentifier:@"ProfileLinksCell"];
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"EventListCell" bundle:nil] forCellReuseIdentifier:@"EventListCell"];
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"FirstLastNameCell" bundle:nil] forCellReuseIdentifier:@"FirstLastNameCell"];
    [self.userProfileTableView registerNib:[UINib nibWithNibName:@"LogoutCell" bundle:nil] forCellReuseIdentifier:@"LogoutCell"];
    self.userProfileTableView.delegate = self;
    self.userProfileTableView.dataSource = self;
    
    // Add user profile photo
    self.userProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height, self.view.frame.size.width/3, self.view.frame.size.width/3)];
    [self.userProfileImageView setClipsToBounds:YES];
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width/2;
    [self.userProfileImageView setImage:[UIImage imageNamed:@"default_profile"]];
    [self.userProfileImageView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.userProfileImageView];
    
    // Add username label
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height, 100, 20)];
    [self.view addSubview:self.usernameLabel];
    [self.usernameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.usernameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[self.usernameLabel.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor] setActive:YES];
    [[self.usernameLabel.heightAnchor constraintEqualToConstant:20] setActive:YES];
    [self.usernameLabel setFont:[UIFont fontWithName:@"roboto" size:20]];
    [self.usernameLabel setClipsToBounds:YES];
    self.usernameLabel.layer.cornerRadius = 5;
    [self.usernameLabel setText:[NSString stringWithFormat:@"@%@", [UserInSession shared].sharedUser.usernameString]];
    [self.usernameLabel sizeToFit];
    [self.usernameLabel setCenter:CGPointMake(self.view.center.x, self.usernameLabel.center.y)];
    [self.usernameLabel setLayoutMargins:UIEdgeInsetsMake(5, 10, 5, 10)];
    [self.usernameLabel setBackgroundColor:UIColorFromRGB(0x79e1c1)];
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    long row = indexPath.row;
    if (row == 0) {
        FirstLastNameCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"FirstLastNameCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        return cell;
    } else if (row == 1) {
        BioCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"BioCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        return cell;
    } else if (row == 2){
        EventListCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"EventListCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        return cell;
    } else if (row == 3){
        EventListCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"EventListCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        [cell.title setText:@"Events Created"];
        return cell;
    } else if (row == 4){
        ProfileLinksCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"ProfileLinksCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        return cell;
    } else {
        LogoutCell *cell = [self.userProfileTableView dequeueReusableCellWithIdentifier:@"LogoutCell"];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        [cell setDelegate:self];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
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


- (void) logoutUser {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    } else {
        NSLog(@"Successfully signedout user %@", [FIRAuth auth].currentUser);
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
        [self.delegate dismissViewController];
    }
}

@end
