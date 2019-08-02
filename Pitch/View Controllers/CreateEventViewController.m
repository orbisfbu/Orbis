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
#import "Vibes.h"
#import "CustomCollectionViewCell.h"
#import "MBCircularProgressBarView.h"

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


@interface CreateEventViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

//@property (strong, nonatomic) FBSDKLoginButton *FBLoginButton;
@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
//@property (strong, nonatomic) NSMutableArray *customPollCellsArray;
//@property (strong, nonatomic) User *makingUser;
//@property (strong, nonatomic) UITableView *createEventTableView;
@property (strong, nonatomic) UIButton *createEventButton;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) NSArray *vibesArray;

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
@property (strong, nonatomic) UILabel *datePickerLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIImageView *pinImageView;

// Location View
@property (strong, nonatomic) UIButton *locationCancelButton;
@property (strong, nonatomic) UITableView *searchResultsTableView;
@property BOOL shouldFireGETRequest; // BOOL for checking whether to call Foursquare API
@property (strong, nonatomic) NSMutableArray<SearchResult *> *recentSearchResults;

// Details View
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) UILabel *vibesLabel;
@property (strong, nonatomic) UICollectionView *vibesCollectionView;
@property (strong, nonatomic) UILabel *ageLabel;
@property (strong, nonatomic) UIView *ageSubview;
@property (strong, nonatomic) MBCircularProgressBarView *leftAgeRestriction;
@property (strong, nonatomic) MBCircularProgressBarView *rightAgeRestriction;

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
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:self.tap];
    self.vibesArray = [[Vibes sharedVibes] getVibesArray];
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
    
    // Create Date Picker Label
    self.datePickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.datePickerLabel setText:@"Date"];
    [self.datePickerLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.datePickerLabel];
    
    // Create date picker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 150)];
    [self.datePicker addTarget:self action:@selector(pickerValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    
    // Create Date Label
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yy, h:mm a"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    CGSize size = [[NSString stringWithFormat:@"%@", date] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:13]}];
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - X_OFFSET - size.width, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", date]];
    [self.dateLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:13]];
    [self.view addSubview:self.dateLabel];
    
    // Create Search Location Text Field
    self.searchLocationTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, self.view.frame.size.height, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT)];
    [self.searchLocationTextField addTarget:self action:@selector(displayLocationView) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchLocationTextField addTarget:self action:@selector(dismissLocationView) forControlEvents:UIControlEventEditingDidEnd];
    [self.searchLocationTextField addTarget:self action:@selector(refreshResultsTableView) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.searchLocationTextField];
    
    // Create Cancel Button
    size = [@"Cancel" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:20]}];
    self.locationCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - size.width - 15, self.view.frame.size.height, size.width, LABEL_HEIGHT)];
    [self.locationCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.locationCancelButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.locationCancelButton addTarget:self action:@selector(locationCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationCancelButton];
    
    // Create Next Button
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height - LABEL_HEIGHT - 4*X_OFFSET, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    self.nextButton.layer.cornerRadius = 5;
    [self.view addSubview:self.nextButton];
    
    // Create Search Results Table View
    self.searchResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, self.view.frame.size.height/2.1)];
    self.searchResultsTableView.layer.cornerRadius = 5;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    [self.view addSubview:self.searchResultsTableView];
    
    // Create Description Label
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.descriptionLabel setText:@"Description"];
    [self.view addSubview:self.descriptionLabel];

    // Create Description text Field
    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 3*LABEL_HEIGHT)];
    self.descriptionTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Use this to tell people about your event" attributes:nil];
    self.descriptionTextView.layer.cornerRadius = 5;
    [self.descriptionTextView setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    [self.view addSubview:self.descriptionTextView];
    
    // Create Vibes Label
    self.vibesLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.vibesLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.vibesLabel setText:@"Vibes/Themes"];
    [self.view addSubview:self.vibesLabel];
    
    // Create Vibes Collection View
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.vibesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 1.3*LABEL_HEIGHT) collectionViewLayout:layout];
    self.vibesCollectionView.layer.cornerRadius = 5;
    [self.vibesCollectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CustomCollectionViewCell"];
    self.vibesCollectionView.delegate = self;
    self.vibesCollectionView.dataSource = self;
    [self.vibesCollectionView setAlwaysBounceHorizontal:YES];
    [self.vibesCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.vibesCollectionView setBackgroundColor:UIColorFromRGB(0x21ce99)];
    [self.vibesCollectionView setAllowsMultipleSelection:YES];
    [self.view addSubview:self.vibesCollectionView];
    
    // Create Age Label
    self.ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.ageLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.ageLabel setText:@"Age Restrictions"];
    [self.view addSubview:self.ageLabel];
    
    // Create Age Restrictions
    self.ageSubview = [[UIView alloc] initWithFrame:CGRectMake(X_OFFSET, self.view.frame.size.height, self.view.frame.size.width - 2*X_OFFSET, 2*LABEL_HEIGHT)];
    [self.ageSubview setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    self.leftAgeRestriction = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake((self.leftAgeRestriction.superview.frame.size.width - 4*X_OFFSET - 50)/2, self.view.frame.size.height/2, 2*X_OFFSET, 2*X_OFFSET)];
    [self.ageSubview addSubview:self.leftAgeRestriction];
    self.rightAgeRestriction = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake(self.rightAgeRestriction.superview.frame.size.width - 2*X_OFFSET - self.leftAgeRestriction.frame.origin.x, self.view.frame.size.height, 2*X_OFFSET, 2*X_OFFSET)];
    [self.ageSubview addSubview:self.rightAgeRestriction];
    
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
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height + 30, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, self.datePickerLabel.frame.origin.y, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.datePickerLabel.frame.origin.y + self.datePickerLabel.frame.size.height - 5, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
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
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, -self.datePickerLabel.frame.size.height, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, -self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, -self.dateLabel.frame.size.height, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.pinImageView.frame = CGRectMake(self.pinImageView.frame.origin.x, -self.pinImageView.frame.size.height, self.pinImageView.frame.size.width, self.pinImageView.frame.size.height);
        [self.backButton setAlpha:1];
    }];
}

- (void) displayLocationView {
    [self.view removeGestureRecognizer:self.tap];
    [self.searchLocationPlaceholderLabel setText:@""];
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, -self.eventTitleLabel.frame.size.height, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, -self.eventTitleTextField.frame.size.height, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, -self.searchLabel.frame.size.height, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, -self.datePickerLabel.frame.size.height, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, -self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, -self.dateLabel.frame.size.height, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.pinImageView.frame = CGRectMake(0, 2*X_OFFSET/3, 1.65*LABEL_HEIGHT, 1.65*LABEL_HEIGHT);
        self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, 2*X_OFFSET/3, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width), 2*LABEL_HEIGHT);
        self.searchLocationPlaceholderLabel.frame = self.searchLocationTextField.frame;
        [self.searchLocationTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:30]];
        self.locationCancelButton.frame = CGRectMake(self.locationCancelButton.frame.origin.x, 1.2*X_OFFSET, self.locationCancelButton.frame.size.width, self.locationCancelButton.frame.size.height);
        self.searchResultsTableView.frame = CGRectMake(self.searchResultsTableView.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height, self.searchResultsTableView.frame.size.width, self.searchResultsTableView.frame.size.height);
    }];
    self.datePicker.alpha = 0;
}

- (void) dismissLocationView {
    [self.view addGestureRecognizer:self.tap];
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, 3*X_OFFSET, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.locationCancelButton.frame = CGRectMake(self.locationCancelButton.frame.origin.x, -self.locationCancelButton.frame.size.height, self.locationCancelButton.frame.size.width, self.locationCancelButton.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, self.eventTitleLabel.frame.origin.y + self.eventTitleLabel.frame.size.height - 10, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.searchLabel.frame = CGRectMake(X_OFFSET, self.eventTitleTextField.frame.origin.y + self.eventTitleTextField.frame.size.height + 30, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT);
        self.pinImageView.frame = CGRectMake(0.8*X_OFFSET, self.searchLocationTextField.frame.origin.y, LABEL_HEIGHT, LABEL_HEIGHT);
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height + 30, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.datePickerLabel.frame.origin.y + self.datePickerLabel.frame.size.height - 5, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, self.datePickerLabel.frame.origin.y, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.searchResultsTableView.frame = CGRectMake(self.searchResultsTableView.frame.origin.x, self.view.frame.size.height, self.searchResultsTableView.frame.size.width, self.searchResultsTableView.frame.size.height);
        if ([self.searchLocationTextField.text isEqualToString:@""]) {
            [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
            self.searchLocationPlaceholderLabel.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, self.searchLocationTextField.frame.origin.y + 5, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        }
        self.datePicker.alpha = 1;
    } completion:^(BOOL finished) {
        self.locationCancelButton.frame = CGRectMake(self.locationCancelButton.frame.origin.x, self.view.frame.size.height, self.locationCancelButton.frame.size.width, self.locationCancelButton.frame.size.height);
    }];
}

- (void) displayDetailsPage {
    self.pageName = DETAILS_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
        self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 10, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
        self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, self.descriptionTextView.frame.origin.y + self.descriptionTextView.frame.size.height + 10, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
        self.vibesCollectionView.frame = CGRectMake(self.vibesCollectionView.frame.origin.x, self.vibesLabel.frame.origin.y + self.vibesLabel.frame.size.height + 10, self.vibesCollectionView.frame.size.width, self.vibesCollectionView.frame.size.height);
        self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, self.vibesCollectionView.frame.origin.y + self.vibesCollectionView.frame.size.height + 10, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
        self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, self.ageLabel.frame.origin.y + self.ageLabel.frame.size.height + 10, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
//        self.leftAgeRestriction.frame = CGRectMake(self.leftAgeRestriction.frame.origin.x, self.ageLabel.frame.origin.y + self.ageLabel.frame.size.height + 10, self.leftAgeRestriction.frame.size.width, self.leftAgeRestriction.frame.size.height);
//        self.rightAgeRestriction.frame = CGRectMake(self.rightAgeRestriction.frame.origin.x, self.ageLabel.frame.origin.y + self.ageLabel.frame.size.height + 10, self.rightAgeRestriction.frame.size.width, self.rightAgeRestriction.frame.size.height);
        NSLog(@"%f", self.leftAgeRestriction.frame.origin.x);
        NSLog(@"%f", self.leftAgeRestriction.frame.origin.y);
        NSLog(@"%f", self.leftAgeRestriction.frame.size.width);
        NSLog(@"%f", self.leftAgeRestriction.frame.size.height);
        NSLog(@"%f", self.view.frame.size.width);
    } completion:^(BOOL finished) {
        NSLog(@"%f", self.leftAgeRestriction.frame.origin.x);
        NSLog(@"%f", self.leftAgeRestriction.frame.origin.y);
        NSLog(@"%f", self.leftAgeRestriction.frame.size.width);
        NSLog(@"%f", self.leftAgeRestriction.frame.size.height);
        NSLog(@"%f", self.view.frame.size.width);
    }];
}

- (void) dismissDetailsPage {
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.view.frame.size.height, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
            self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, self.view.frame.size.height, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
            self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, self.view.frame.size.height, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
            self.vibesCollectionView.frame = CGRectMake(self.vibesCollectionView.frame.origin.x, self.view.frame.size.height, self.vibesCollectionView.frame.size.width, self.vibesCollectionView.frame.size.height);
            self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, self.view.frame.size.height, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
            //self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, self.view.frame.size.height, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, -self.descriptionLabel.frame.size.height, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
            self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, -self.descriptionTextView.frame.size.height, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
            self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, -self.vibesLabel.frame.size.height, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
            self.vibesCollectionView.frame = CGRectMake(self.vibesCollectionView.frame.origin.x, -self.vibesCollectionView.frame.size.height, self.vibesCollectionView.frame.size.width, self.vibesCollectionView.frame.size.height);
            self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, -self.ageLabel.frame.size.height, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
            //self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, -self.ageSubview.frame.size.height, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
            
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
                                      @"Created By": @"Sebastian Bernal",
                                      @"Event Name": @"Testing with integers",
                                      @"Has Music": @"YES",
                                      @"Attendance": @56,
                                      @"ImageURL": @"https://bit.ly/2SYp8Za",
                                      @"Description": @"Another cool description",
                                      @"Age Restriction": @69,
                                      @"Location": @"37.777937 -122.415954",
                                      @"Vibes": @[@"Vibe1",@"Vibe2",@"Vibe3"],
                                      @"MinPeople":@"1",
                                      @"MaxPeople":@"500"
                                      };
    Event *eventToAdd = [[Event alloc] initWithDictionary:eventDefinition];
    [[DataHandling shared] addEventToDatabase:eventToAdd];
    [self.delegate refreshAfterEventCreation];
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

- (void) locationCancelButtonPressed {
    [self.searchLocationTextField setText:@""];
    [self dismissKeyboard];
}

- (void) pickerValueChanged {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *strDate = [dateFormatter stringFromDate:self.datePicker.date];
    self.dateLabel.text = strDate;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
    [self.searchLocationTextField setText:[self.recentSearchResults[indexPath.row] getName]];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [self.vibesCollectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionViewCell" forIndexPath:indexPath];
    [cell setLabelText:self.vibesArray[indexPath.item]];
    [cell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.vibesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"CustomCollectionViewCell" owner:self options:nil].firstObject;
    [cell setLabelText:self.vibesArray[indexPath.row]];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return CGSizeMake(size.width, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3 animations:^{
        cell.frame = CGRectMake(cell.frame.origin.x - 5, cell.frame.origin.y - 2.5, cell.frame.size.width + 10, cell.frame.size.height + 5);
    }];
    [cell setBackgroundColor:[UIColor grayColor]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3 animations:^{
        cell.frame = CGRectMake(cell.frame.origin.x + 5, cell.frame.origin.y + 2.5, cell.frame.size.width - 10, cell.frame.size.height - 5);
    }];
    [cell setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
}

@end
