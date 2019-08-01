//
//  CreateEventViewController.m
//  Pitch
//
//  Created by ezietz on 7/23/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "CreateEventViewController.h"
#import "UserViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FirebaseDatabase/FirebaseDatabase.h"
#import "AppDelegate.h"
#import "UserViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FBSDKLoginManagerLoginResult.h"
#import <FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Event.h"
#import "User.h"
#import "DataHandling.h"
#import "VibesCell.h"
#import "AgeCell.h"
#import "EventTitleCell.h"
#import "LocationCell.h"
#import "PollsTitleCell.h"
#import "CustomPollCell.h"
#import <MapKit/MKLocalSearchRequest.h>
#import <MapKit/MKLocalSearch.h>
#import <UITextView+Placeholder.h>
#import "SearchResult.h"

// Constant View Names
static NSString * const INITIAL_VIEW = @"INITIAL_VIEW";
static NSString * const LOCATION_VIEW = @"LOCATION_VIEW";
static NSString * const DETAILS_VIEW = @"DETAILS_VIEW";
static NSString * const MEDIA_VIEW = @"MEDIA_VIEW";
static NSString * const MUSIC_VIEW = @"MUSIC_VIEW";
static NSString * const POLL_VIEW = @"POLL_VIEW";

// Constant Sizes
static int const LABEL_HEIGHT = 30;
static int const X_OFFSET = 30;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@import UIKit;
@import Firebase;
@import FirebaseAuth;
@import UITextView_Placeholder;


//Debugging/Error Messages
static NSString * const SUCCESSFUL_EVENT_SAVE = @"Successfully saved Event info to database";


@interface CreateEventViewController () <UITableViewDelegate, UITableViewDataSource>

//@property (strong, nonatomic) FBSDKLoginButton *FBLoginButton;
@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
//@property (strong, nonatomic) NSMutableArray *customPollCellsArray;
//@property (strong, nonatomic) User *makingUser;
//@property (strong, nonatomic) UITableView *createEventTableView;
@property (strong, nonatomic) UIButton *createEventButton;

// PAGE NAME
@property (strong, nonatomic) NSString *pageName;

// Page Objects
@property (strong, nonatomic) UIButton *nextButton;

// Initial View
@property (strong, nonatomic) UILabel *eventTitleLabel;
@property (strong, nonatomic) UITextField *eventTitleTextField;
@property (strong, nonatomic) UILabel *searchLabel;
@property (strong, nonatomic) UITextField *searchLocationTextField;
@property (strong, nonatomic) UILabel *searchLocationPlaceholderLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIImageView *pinImageView;

// Location View
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UITableView *searchResultsTableView;
@property BOOL shouldFireGETRequest; // BOOL for checking whether to call Foursquare API
@property (strong, nonatomic) NSMutableArray<SearchResult *> *recentSearchResults;

// Details View
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) UILabel *vibesLabel;
@property (strong, nonatomic) UIView *vibesSubview;
@property (strong, nonatomic) UILabel *ageLabel;
@property (strong, nonatomic) UIView *ageSubview;

// Media View
@property (strong, nonatomic) UILabel *coverImageLabel;
@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *additionalMediaLabel;
@property (strong, nonatomic) UIView *additionalMediaSubview;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldFireGETRequest = NO;
    [self.view setBackgroundColor:UIColorFromRGB(0x21ce99)];
    [self.backButton setAlpha:0];
    [self.backButton setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self createPageObjects];
    [self displayInitialPage];
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) createPageObjects {
    
    // Create Event Title Text Label
    self.eventTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2 * X_OFFSET, LABEL_HEIGHT)];
    [self.eventTitleLabel setText:@"Title"];
    [self.eventTitleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.eventTitleLabel];
    
    // Create Event Title Text Field
    self.eventTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2 * X_OFFSET, 2*LABEL_HEIGHT)];
    [self.eventTitleTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:40]];
    [self.eventTitleTextField setMinimumFontSize:30];
    [self.eventTitleTextField setAdjustsFontSizeToFitWidth:YES];
    [self.eventTitleTextField setPlaceholder:@"E.g Yika's Bday"];
    [self.view addSubview:self.eventTitleTextField];
    
    // Create Search Label
    self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.searchLabel setText:@"Location"];
    [self.searchLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.searchLabel];
    
    // Create a Pin Image View
    self.pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.8*X_OFFSET, self.view.frame.size.height, LABEL_HEIGHT, LABEL_HEIGHT)];
    [self.pinImageView setImage:[UIImage imageNamed:@"pin"]];
    [self.view addSubview:self.pinImageView];
    
    // Create Search Location Placeholder Label
    self.searchLocationPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, self.view.frame.size.height, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + X_OFFSET), LABEL_HEIGHT)];
    [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
    [self.searchLocationPlaceholderLabel setAlpha:0.2];
    [self.searchLocationPlaceholderLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    [self.view addSubview:self.searchLocationPlaceholderLabel];
    
    // Create Search Location Text Field
    self.searchLocationTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, self.view.frame.size.height, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT)];
    [self.searchLocationTextField addTarget:self action:@selector(displayLocationView) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchLocationTextField addTarget:self action:@selector(dismissLocationView) forControlEvents:UIControlEventEditingDidEnd];
    [self.searchLocationTextField addTarget:self action:@selector(refreshResultsTableView) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.searchLocationTextField];
    
    // Create date picker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 150)];
    [self.view addSubview:self.datePicker];
    
    // Create Cancel Button
    CGSize size = [@"Cancel" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:20]}];
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - size.width - 15, self.view.frame.size.height, size.width, LABEL_HEIGHT)];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.cancelButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    // Create Next Button
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height - LABEL_HEIGHT - 3 * X_OFFSET, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    // Create Search Results Table View
    self.searchResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, self.view.frame.size.height/2.1)];
    self.searchResultsTableView.layer.cornerRadius = 5;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    [self.view addSubview:self.searchResultsTableView];
    
    // Create Description Label
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.descriptionLabel setText:@"Description"];
    [self.view addSubview:self.descriptionLabel];

    // Create Description text Field
    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 2*LABEL_HEIGHT)];
    self.descriptionTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Use this to tell people about your event" attributes:nil];
    [self.view addSubview:self.descriptionTextView];
    
    // Create Vibes Label
    self.vibesLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.vibesLabel setText:@"Vibes/Themes"];
    [self.view addSubview:self.vibesLabel];
    
    // Create Vibes Sub View
    self.vibesSubview = [[UIView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 1.5 * LABEL_HEIGHT)];
    [self.view addSubview:self.vibesSubview];
    
    // Create Age Label
    self.ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.ageLabel setText:@"Age Restrictions"];
    [self.view addSubview:self.ageLabel];
    
    // Create Age Sub View
    self.ageSubview = [[UIView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 1.5 * LABEL_HEIGHT)];

    [self.view addSubview:self.ageSubview];
    
    // Create Cover Image Label
    self.coverImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.coverImageLabel setText:@"Cover Image"];
    [self.view addSubview:self.coverImageLabel];
    
    // Create Cover Image View
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 3 * LABEL_HEIGHT)];
    [self.view addSubview:self.coverImageView];
    
    // Create Additional Media Label
    self.additionalMediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.additionalMediaLabel setText:@"Additional Media"];
    [self.view addSubview:self.additionalMediaLabel];

    // Create Additional Meida Subview
    self.additionalMediaSubview = [[UIImageView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 3*LABEL_HEIGHT)];
    [self.view addSubview:self.additionalMediaSubview];
}

- (void) displayInitialPage {
    self.pageName = INITIAL_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, 3*X_OFFSET, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, self.eventTitleLabel.frame.origin.y + self.eventTitleLabel.frame.size.height - 10, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, self.eventTitleTextField.frame.origin.y + self.eventTitleTextField.frame.size.height + 30, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.searchLocationPlaceholderLabel.frame = CGRectMake(self.searchLocationPlaceholderLabel.frame.origin.x, self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height, self.searchLocationPlaceholderLabel.frame.size.width, self.searchLocationPlaceholderLabel.frame.size.height);
        self.searchLocationTextField.frame = CGRectMake(self.searchLocationTextField.frame.origin.x, self.searchLocationPlaceholderLabel.frame.origin.y, self.searchLocationTextField.frame.size.width, self.searchLocationTextField.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height + 30, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.pinImageView.frame = CGRectMake(self.pinImageView.frame.origin.x, self.searchLocationTextField.frame.origin.y, self.pinImageView.frame.size.width, self.pinImageView.frame.size.height);
    }];
}

- (void) dismissInitialPage {
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, -self.eventTitleLabel.frame.size.height, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, -self.eventTitleTextField.frame.size.height, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, -self.searchLabel.frame.size.height, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.searchLocationPlaceholderLabel.frame = CGRectMake(self.searchLocationPlaceholderLabel.frame.origin.x, -self.searchLocationPlaceholderLabel.frame.size.height, self.searchLocationPlaceholderLabel.frame.size.width, self.searchLocationPlaceholderLabel.frame.size.height);
        self.searchLocationTextField.frame = CGRectMake(self.searchLocationTextField.frame.origin.x, -self.searchLocationTextField.frame.size.height, self.searchLocationTextField.frame.size.width, self.searchLocationTextField.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, -self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.pinImageView.frame = CGRectMake(self.pinImageView.frame.origin.x, -self.pinImageView.frame.size.height, self.pinImageView.frame.size.width, self.pinImageView.frame.size.height);
        [self.backButton setAlpha:1];
    }];
}

- (void) displayLocationView {
    [self.searchLocationPlaceholderLabel setText:@""];
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, -self.eventTitleLabel.frame.size.height, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, -self.eventTitleTextField.frame.size.height, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, -self.searchLabel.frame.size.height, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, -self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.pinImageView.frame = CGRectMake(0, 2*X_OFFSET/3, 1.65*LABEL_HEIGHT, 1.65*LABEL_HEIGHT);
        self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, 2*X_OFFSET/3, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width), 2*LABEL_HEIGHT);
        self.searchLocationPlaceholderLabel.frame = self.searchLocationTextField.frame;
        [self.searchLocationTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:30]];
        self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, 1.2*X_OFFSET, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
        self.searchResultsTableView.frame = CGRectMake(self.searchResultsTableView.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height, self.searchResultsTableView.frame.size.width, self.searchResultsTableView.frame.size.height);
    }];
    self.datePicker.alpha = 0;
}

- (void) dismissLocationView {
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, 3*X_OFFSET, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, -self.cancelButton.frame.size.height, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, self.eventTitleLabel.frame.origin.y + self.eventTitleLabel.frame.size.height - 10, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.searchLabel.frame = CGRectMake(X_OFFSET, self.eventTitleTextField.frame.origin.y + self.eventTitleTextField.frame.size.height + 30, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT);
        self.pinImageView.frame = CGRectMake(0.8*X_OFFSET, self.searchLocationTextField.frame.origin.y, LABEL_HEIGHT, LABEL_HEIGHT);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height + 30, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.searchResultsTableView.frame = CGRectMake(self.searchResultsTableView.frame.origin.x, self.view.frame.size.height, self.searchResultsTableView.frame.size.width, self.searchResultsTableView.frame.size.height);
        if ([self.searchLocationTextField.text isEqualToString:@""]) {
            [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
            self.searchLocationPlaceholderLabel.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, self.searchLocationTextField.frame.origin.y + 5, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        }
        self.datePicker.alpha = 1;
    } completion:^(BOOL finished) {
        self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, self.view.frame.size.height, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
    }];
}

- (void) displayDetailsPage {
    self.pageName = DETAILS_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
        self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 10, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
        self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, self.descriptionTextView.frame.origin.y + self.descriptionTextView.frame.size.height + 10, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
        self.vibesSubview.frame = CGRectMake(self.vibesSubview.frame.origin.x, self.vibesLabel.frame.origin.y + self.vibesLabel.frame.size.height + 10, self.vibesSubview.frame.size.width, self.vibesSubview.frame.size.height);
        self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, self.vibesSubview.frame.origin.y + self.vibesSubview.frame.size.height + 10, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
        self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, self.ageLabel.frame.origin.y + self.ageLabel.frame.size.height + 10, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
    }];
}

- (void) dismissDetailsPage {
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.view.frame.size.height, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
            self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, self.view.frame.size.height, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
            self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, self.view.frame.size.height, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
            self.vibesSubview.frame = CGRectMake(self.vibesSubview.frame.origin.x, self.view.frame.size.height, self.vibesSubview.frame.size.width, self.vibesSubview.frame.size.height);
            self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, self.view.frame.size.height, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
            self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, self.view.frame.size.height, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, -self.descriptionLabel.frame.size.height, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
            self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, -self.descriptionTextView.frame.size.height, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
            self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, -self.vibesLabel.frame.size.height, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
            self.vibesSubview.frame = CGRectMake(self.vibesSubview.frame.origin.x, -self.vibesSubview.frame.size.height, self.vibesSubview.frame.size.width, self.vibesSubview.frame.size.height);
            self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, -self.ageLabel.frame.size.height, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
            self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, -self.ageSubview.frame.size.height, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
            
        }];
    }
}

- (void) displayMediaPage {
    self.pageName = MEDIA_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.coverImageLabel.frame = CGRectMake(self.coverImageLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.coverImageLabel.frame.size.width, self.coverImageLabel.frame.size.height);
        self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x, self.coverImageLabel.frame.origin.y + self.coverImageLabel.frame.size.height + 10, self.coverImageView.frame.size.width, self.coverImageView.frame.size.height);
        self.additionalMediaLabel.frame = CGRectMake(self.additionalMediaLabel.frame.origin.x, self.coverImageView.frame.origin.y + self.coverImageView.frame.size.height + 10, self.additionalMediaLabel.frame.size.width, self.additionalMediaLabel.frame.size.height);
        self.additionalMediaSubview.frame = CGRectMake(self.additionalMediaSubview.frame.origin.x, self.additionalMediaLabel.frame.origin.y + self.additionalMediaLabel.frame.size.height + 10, self.additionalMediaSubview.frame.size.width, self.additionalMediaSubview.frame.size.height);
    }];
}


- (void) dismissMediaPage {
    if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.coverImageLabel.frame = CGRectMake(self.coverImageLabel.frame.origin.x, self.view.frame.size.height, self.coverImageLabel.frame.size.width, self.coverImageLabel.frame.size.height);
            self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x, self.view.frame.size.height, self.coverImageView.frame.size.width, self.coverImageView.frame.size.height);
            self.additionalMediaLabel.frame = CGRectMake(self.additionalMediaLabel.frame.origin.x, self.view.frame.size.height, self.additionalMediaLabel.frame.size.width, self.additionalMediaLabel.frame.size.height);
            self.additionalMediaSubview.frame = CGRectMake(self.additionalMediaSubview.frame.origin.x, self.view.frame.size.height, self.additionalMediaSubview.frame.size.width, self.additionalMediaSubview.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.coverImageLabel.frame = CGRectMake(self.coverImageLabel.frame.origin.x, -self.coverImageLabel.frame.size.height, self.coverImageLabel.frame.size.width, self.coverImageLabel.frame.size.height);
            self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x, -self.coverImageView.frame.size.height, self.coverImageView.frame.size.width, self.coverImageView.frame.size.height);
            self.additionalMediaLabel.frame = CGRectMake(self.additionalMediaLabel.frame.origin.x, -self.additionalMediaLabel.frame.size.height, self.additionalMediaLabel.frame.size.width, self.additionalMediaLabel.frame.size.height);
            self.additionalMediaSubview.frame = CGRectMake(self.additionalMediaSubview.frame.origin.x, -self.additionalMediaSubview.frame.size.height, self.additionalMediaSubview.frame.size.width, self.additionalMediaSubview.frame.size.height);
        }];
    }
}

- (void) createEventButtonPressed {
    NSDictionary *eventDefinition = @{
                                      @"Created By": @"Elizabeth",
                                      @"Event Name": @"Event after eventDetails",
                                      @"Has Music": @"YES",
                                      @"Attendance": @"8",
                                      @"ImageURL": @"https://www.google.com/url?sa=i&source=images&cd=&ved=2ahUKEwj_15rNj9vjAhVFu54KHQWyDXAQjRx6BAgBEAU&url=https%3A%2F%2Fwww.festicket.com%2Fmagazine%2Fdiscover%2Ftop-20-music-festivals-Europe%2F&psig=AOvVaw2JAA6zSvLSfHHv1W1_awOl&ust=1564523774410326",
                                      @"Description": @"testing",
                                      @"Age Restriction": @"21",
                                      @"Location": @"37.735390 -122.501310"
                                      };
    Event *eventToAdd = [[Event alloc] initWithDictionary:eventDefinition];
    [[DataHandling shared] addEventToDatabase:eventToAdd];
    EventAnnotation *newEventAnnotation = [[EventAnnotation alloc] init];
    newEventAnnotation.coordinate = eventToAdd.eventCoordinates;
    newEventAnnotation.eventName = eventToAdd.eventName;
    newEventAnnotation.eventCreator = eventToAdd.eventCreator;
    newEventAnnotation.eventDescription = eventToAdd.eventDescription;
    newEventAnnotation.eventAgeRestriction = eventToAdd.eventAgeRestriction;
    newEventAnnotation.eventAttendanceCount = eventToAdd.eventAttendanceCount;
    [self.delegate addThisAnnotationToMap:newEventAnnotation];
}

- (void) nextButtonPressed {
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        [self dismissInitialPage];
        [self displayDetailsPage];
    } else if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        [self dismissDetailsPage];
        [self displayMediaPage];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.backButton setAlpha:0];
        }];
        [self displayInitialPage];
        [self dismissDetailsPage];
    } else if ([self.pageName isEqualToString:MEDIA_VIEW]) {
        [self displayDetailsPage];
        [self dismissMediaPage];
    }
}

- (void) refreshResultsTableView {
    NSString *coordinates = @"37.77,-122.41";
    NSString *query = self.searchLocationTextField.text;
    NSString *CLIENT_ID = @"3NZPO204JPDCJW0XJWY5AFCWCLXNZWDNIOHTQYHHOP0ARXRI";
    NSString *CLIENT_SECRET = @"ASWMRXJPXFIX0D3NWMOWSVHKID52USWCSA402SQLWD0CQHFS";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSString *URLString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/suggestcompletion?ll=%@&query=%@&client_id=%@&client_secret=%@&v=%@", coordinates, query, CLIENT_ID, CLIENT_SECRET, date];
    NSLog(@"%@", URLString);
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"ERROR RETRIEVING SEARCH RESULTS: %@", error);
        } else {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *responseDict = dataDict[@"response"];
            NSDictionary *venuesDict = responseDict[@"minivenues"];
            self.recentSearchResults = [[NSMutableArray alloc] init];
            for (NSDictionary *venueDict in venuesDict) {
                NSLog(@"INSIDE FOR LOOP");
                SearchResult *result = [[SearchResult alloc] initWithDictionary:venueDict];
                [self.recentSearchResults addObject:result];
            }
            [self.searchResultsTableView reloadData];
        }
    }];
    [task resume];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [(SearchResult *)self.recentSearchResults[indexPath.row] getName]]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentSearchResults.count;
}

@end
