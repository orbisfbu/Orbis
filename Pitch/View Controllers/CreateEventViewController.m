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
#import "MusicQueueCollectionViewCell.h"
#import "Song.h"
#import "MediaCollectionViewCell.h"


// Constant View Names
static NSString * const INITIAL_VIEW = @"INITIAL_VIEW";
static NSString * const LOCATION_VIEW = @"LOCATION_VIEW";
static NSString * const DETAILS_VIEW = @"DETAILS_VIEW";
static NSString * const MEDIA_VIEW = @"MEDIA_VIEW";
static NSString * const MUSIC_VIEW = @"MUSIC_VIEW";
static NSString * const POLL_VIEW = @"POLL_VIEW";

static NSInteger const BACKGROUND_GREEN = 0x21ce99;
static NSInteger const LIGHT_GREEN = 0xd2f5ea;
static NSInteger const DARK_GREEN = 0x157f5f;
static NSInteger const LABEL_GREEN = 0x0d523d;
// Constant Sizes
static int const LABEL_HEIGHT = 30;
static int const X_OFFSET = 30;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define MAXLENGTH 20

@import UIKit;
@import Firebase;
@import FirebaseAuth;
@import UITextView_Placeholder;


//Debugging/Error Messages
static NSString * const SUCCESSFUL_EVENT_SAVE = @"Successfully saved Event info to database";


@interface CreateEventViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *databaseEventsReference;
@property (strong, nonatomic) FIRDatabaseReference *databaseUsersReference;
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
@property (strong, nonatomic) UILabel *charsLeftInTitleLabel;
@property (strong, nonatomic) UILabel *searchLabel;
@property (strong, nonatomic) UITextField *searchLocationTextField;
@property (strong, nonatomic) UILabel *searchLocationPlaceholderLabel;
@property (strong, nonatomic) UILabel *datePickerLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSString *eventStartDateString;
@property (strong, nonatomic) UIImageView *pinImageView;

// Location View
@property (strong, nonatomic) UIButton *locationCancelButton;
@property (strong, nonatomic) UITableView *searchResultsTableView;
@property BOOL shouldFireGETRequest; // BOOL for checking whether to call Foursquare API
@property (strong, nonatomic) NSMutableArray <SearchResult *> *recentSearchResults;
@property (nonatomic) CLLocationCoordinate2D coordinates;

// Details View
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) UILabel *vibesLabel;
@property (strong, nonatomic) UICollectionView *vibesCollectionView;
@property (strong, nonatomic) UILabel *ageLabel;
@property (strong, nonatomic) UIView *ageSubview;
@property int ageRestriction;
@property (strong, nonatomic) MBCircularProgressBarView *leftAgeRestriction;
@property (strong, nonatomic) MBCircularProgressBarView *rightAgeRestriction;
@property (strong, nonatomic) NSMutableSet *vibesSet;

// Media View
@property (strong, nonatomic) UILabel *coverImageLabel;
@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *additionalMediaLabel;
@property (strong, nonatomic) UICollectionView *additionalMediaCollectionView;
@property (strong, nonatomic) NSMutableArray *additionalImages;
@property BOOL isCoverImage;

// Music View
@property (strong, nonatomic) UILabel *musicPageDescriptionLabel;
@property (strong, nonatomic) UITextField *searchMusicTextField;
@property (strong, nonatomic) UIImageView *musicNoteImageView;
@property (strong, nonatomic) UILabel *musicQueueLabel;
@property (strong, nonatomic) UITableView *musicResultsTableView;
@property (strong, nonatomic) UIButton *musicCancelButton;
@property (strong, nonatomic) UICollectionView *musicQueueCollectionView;
@property (strong, nonatomic) NSMutableArray *songsArray;
@property (strong, nonatomic) NSMutableArray *queuedUpSongsArray;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isCoverImage = YES;
    self.vibesSet = [[NSMutableSet alloc] init];
    [self createSongsArray];
    [self createAdditionalImagesArray];
    self.ageRestriction = 0;
    self.shouldFireGETRequest = NO;
    [self.view setBackgroundColor:UIColorFromRGB(BACKGROUND_GREEN)];
    [self.backButton setAlpha:0];
    [self.backButton setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:self.tap];
    self.vibesArray = [[Vibes sharedVibes] getVibesArray];
    [self createPageObjects];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.eventStartDateString = [dateFormatter stringFromDate:self.datePicker.date];
    
    [self displayInitialPage];
}

- (void) createAdditionalImagesArray {
    self.additionalImages = [[NSMutableArray alloc] init];
    [self.additionalImages addObject:[UIImage imageNamed:@"plus"]];
}

- (void) createSongsArray {
    
    self.songsArray = [[NSMutableArray alloc] init];
    
    Song *song = [[Song alloc] init];
    [song setTitle:@"Jocelyn Flores"];
    [song setArtistName:@"XXXTENTACION"];
    [song setAlbumName:@"17"];
    [song setNumLikes:0];
    [song setUserIDsThatHaveLikedSong:[[NSMutableArray alloc] init]];
    [self.songsArray addObject:song];

    song = [[Song alloc] init];
    [song setTitle:@"Saviers Road"];
    [song setArtistName:@"Anderson .Paak"];
    [song setAlbumName:@"Oxnard"];
    [song setNumLikes:0];
    [song setUserIDsThatHaveLikedSong:[[NSMutableArray alloc] init]];
    [self.songsArray addObject:song];
    
    song = [[Song alloc] init];
    [song setTitle:@"Bound 2"];
    [song setArtistName:@"Kanye West"];
    [song setAlbumName:@"Yeezus"];
    [song setNumLikes:0];
    [song setUserIDsThatHaveLikedSong:[[NSMutableArray alloc] init]];
    [self.songsArray addObject:song];
    
    song = [[Song alloc] init];
    [song setTitle:@"Stepping Stone"];
    [song setArtistName:@"Eminem"];
    [song setAlbumName:@"Kamikaze"];
    [song setNumLikes:0];
    [song setUserIDsThatHaveLikedSong:[[NSMutableArray alloc] init]];
    [self.songsArray addObject:song];
    
    song = [[Song alloc] init];
    [song setTitle:@"Lucy In The Sky With Diamonds"];
    [song setArtistName:@"The Beatles"];
    [song setAlbumName:@"Sgt. Pepper's Lonely Hearts Club"];
    [song setNumLikes:0];
    [song setUserIDsThatHaveLikedSong:[[NSMutableArray alloc] init]];
    [self.songsArray addObject:song];
    
    self.queuedUpSongsArray = [[NSMutableArray alloc] init];
    song = [[Song alloc] init];
    [song setTitle:@"Title"];
    [song setArtistName:@"Artist"];
    [song setAlbumName:@"plus"];
    [song setNumLikes:0];
    [song setUserIDsThatHaveLikedSong:[[NSMutableArray alloc] init]];
    [self.queuedUpSongsArray addObject:song];
}

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) createPageObjects {
    // Create Event Title Text Label
    self.eventTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.eventTitleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    NSString *titleText = @"Title*";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleText];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(titleText.length - 1, 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(LABEL_GREEN) range:NSMakeRange(0, titleText.length - 1)];
    self.eventTitleLabel.attributedText = attributedString;
    [self.view addSubview:self.eventTitleLabel];
    
    // Create Event Title Text Field
    self.eventTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 2*LABEL_HEIGHT)];
    [self.eventTitleTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:40]];
    [self.eventTitleTextField setMinimumFontSize:20];
    [self.eventTitleTextField setAdjustsFontSizeToFitWidth:YES];
    [self.eventTitleTextField setPlaceholder:@"E.g Yike's Bday"];
    self.eventTitleTextField.delegate = self;
    [self.eventTitleTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.eventTitleTextField];
    
    // Create Chars Left In Title Label
    CGSize size = [[NSString stringWithFormat:@"(%d)", MAXLENGTH] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:15]}];
    self.charsLeftInTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - X_OFFSET - size.width, [[UIScreen mainScreen] bounds].size.height, size.width, LABEL_HEIGHT)];
    [self.charsLeftInTitleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.charsLeftInTitleLabel setText:[NSString stringWithFormat:@"(%d)", MAXLENGTH]];
    [self.charsLeftInTitleLabel setTextColor:UIColorFromRGB(DARK_GREEN)];
    [self.view addSubview:self.charsLeftInTitleLabel];
    
    // Create Location Label
    self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.searchLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    titleText = @"Location*";
    attributedString = [[NSMutableAttributedString alloc] initWithString:titleText];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(titleText.length - 1, 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(LABEL_GREEN) range:NSMakeRange(0, titleText.length - 1)];
    self.searchLabel.attributedText = attributedString;
    [self.view addSubview:self.searchLabel];
    
    // Create a Pin Image View
    self.pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.8*X_OFFSET, [[UIScreen mainScreen] bounds].size.height, LABEL_HEIGHT, LABEL_HEIGHT)];
    [self.pinImageView setImage:[UIImage imageNamed:@"pin"]];
    [self.view addSubview:self.pinImageView];
    
    // Create Search Location Placeholder Label
    self.searchLocationPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + X_OFFSET), LABEL_HEIGHT)];
    [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
    [self.searchLocationPlaceholderLabel setAlpha:0.2];
    [self.searchLocationPlaceholderLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    [self.view addSubview:self.searchLocationPlaceholderLabel];
    
    // Create Date Picker Label
    self.datePickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.datePickerLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    titleText = @"Date*";
    attributedString = [[NSMutableAttributedString alloc] initWithString:titleText];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(titleText.length - 1, 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(LABEL_GREEN) range:NSMakeRange(0, titleText.length - 1)];
    self.datePickerLabel.attributedText = attributedString;
    [self.view addSubview:self.datePickerLabel];
    
    // Create date picker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 150)];
    [self.datePicker setMinimumDate: [NSDate date]];
    self.datePicker.subviews[0].subviews[1].backgroundColor = [UIColor colorWithRed:(19/255.0) green:(123/255.0) blue:(91/255.0) alpha:1];
    self.datePicker.subviews[0].subviews[2].backgroundColor = [UIColor colorWithRed:(19/255.0) green:(123/255.0) blue:(91/255.0) alpha:1];
    [self.datePicker setValue:UIColorFromRGB(DARK_GREEN) forKey:@"textColor"];
    [self.datePicker addTarget:self action:@selector(pickerValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    
    // Create Date Label
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yy, h:mm a"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    size = [[NSString stringWithFormat:@"%@", date] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:15]}];
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - X_OFFSET - size.width, [[UIScreen mainScreen] bounds].size.height, size.width, LABEL_HEIGHT)];
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", date]];
    [self.dateLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.view addSubview:self.dateLabel];
    
    // Create Search Location Text Field
    self.searchLocationTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT)];
    self.searchLocationTextField.adjustsFontSizeToFitWidth = YES;
    // self.searchLocationTextField.textColor = [UIColor colorWithRed:(19/255.0) green:(123/255.0) blue:(91/255.0) alpha:1] ;
    [self.searchLocationTextField addTarget:self action:@selector(displayLocationView) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchLocationTextField addTarget:self action:@selector(dismissLocationView) forControlEvents:UIControlEventEditingDidEnd];
    [self.searchLocationTextField addTarget:self action:@selector(refreshResultsTableView) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.searchLocationTextField];
    
    // Create Location Cancel Button
    CGSize locationCancelButtonSize = [@"Cancel" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:20]}];
    self.locationCancelButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - locationCancelButtonSize.width - 15, [[UIScreen mainScreen] bounds].size.height, locationCancelButtonSize.width, LABEL_HEIGHT)];
    [self.locationCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.locationCancelButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.locationCancelButton addTarget:self action:@selector(locationCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationCancelButton];
    
    // Create Search Results Table View
    self.searchResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.view.frame.size.height/2.1)];
    self.searchResultsTableView.layer.cornerRadius = 5;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    [self.view addSubview:self.searchResultsTableView];
    
    // Create Description Label
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.descriptionLabel setText:@"Description"];
    self.descriptionLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.descriptionLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.descriptionLabel];

    // Create Description text Field
    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 3*LABEL_HEIGHT)];
    self.descriptionTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Use this to tell people about your event..." attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(DARK_GREEN)}];
    self.descriptionTextView.layer.cornerRadius = 5;
    [self.descriptionTextView setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
    [self.descriptionTextView setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    [self.descriptionTextView setTextColor:UIColorFromRGB(DARK_GREEN)];
    [self.view addSubview:self.descriptionTextView];
    
    // Create Vibes Label
    self.vibesLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.vibesLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.vibesLabel setText:@"Vibes/Themes"];
    self.vibesLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.vibesLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.vibesLabel];
    
    // Create Vibes Collection View
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.vibesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 1.3*LABEL_HEIGHT) collectionViewLayout:layout];
    self.vibesCollectionView.layer.cornerRadius = 5;
    [self.vibesCollectionView setRestorationIdentifier:@"vibesCollectionView"];
    [self.vibesCollectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CustomCollectionViewCell"];
    self.vibesCollectionView.delegate = self;
    self.vibesCollectionView.dataSource = self;
    [self.vibesCollectionView setAlwaysBounceHorizontal:YES];
    [self.vibesCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.vibesCollectionView setBackgroundColor:UIColorFromRGB(BACKGROUND_GREEN)];
    [self.vibesCollectionView setAllowsMultipleSelection:YES];
    [self.view addSubview:self.vibesCollectionView];
    
    // Create Age Label
    self.ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.ageLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.ageLabel setText:@"Age Restrictions"];
    [self.ageLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    self.ageLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.view addSubview:self.ageLabel];
    
    // Create Age Restrictions
    self.ageSubview = [[UIView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 3*LABEL_HEIGHT)];
    [self.ageSubview setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    [self.view addSubview:self.ageSubview];
    self.ageSubview.layer.cornerRadius = 5;
    self.leftAgeRestriction = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake(self.ageSubview.frame.size.width - 9*X_OFFSET, 0, 3*X_OFFSET, 3*X_OFFSET)];
    [self.leftAgeRestriction setEmptyLineStrokeColor:UIColorFromRGB(BACKGROUND_GREEN)];
    [self.leftAgeRestriction setProgressColor:UIColorFromRGB(0x137b5b)];
    [self.leftAgeRestriction setProgressLineWidth:5];
    [self.leftAgeRestriction setProgressStrokeColor:UIColorFromRGB(0x137b5b)];
    [self.leftAgeRestriction setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    [self.ageSubview addSubview:self.leftAgeRestriction];
    UIButton *leftLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.leftAgeRestriction.frame.origin.x + 0.9*X_OFFSET, self.leftAgeRestriction.frame.origin.y + X_OFFSET, 40, 35)];
    [leftLabel setTitle:@"18+" forState:UIControlStateNormal];
    [leftLabel.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    [leftLabel setTitleColor:UIColorFromRGB(0x137b5b) forState:UIControlStateNormal];
    [leftLabel setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    leftLabel.layer.cornerRadius = 10;
    [leftLabel addTarget:self action:@selector(leftAgeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.ageSubview addSubview:leftLabel];
    self.rightAgeRestriction = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake(self.ageSubview.frame.size.width - 5*X_OFFSET, 0, 3*X_OFFSET, 3*X_OFFSET)];
    [self.rightAgeRestriction setEmptyLineStrokeColor:UIColorFromRGB(BACKGROUND_GREEN)];
    [self.rightAgeRestriction setProgressColor:UIColorFromRGB(0x137b5b)];
    [self.rightAgeRestriction setProgressLineWidth:5];
    [self.rightAgeRestriction setProgressStrokeColor:UIColorFromRGB(0x137b5b)];
    [self.rightAgeRestriction setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    [self.ageSubview addSubview:self.rightAgeRestriction];
    UIButton *rightLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.rightAgeRestriction.frame.origin.x + 0.9*X_OFFSET, self.rightAgeRestriction.frame.origin.y + X_OFFSET, 40, 35)];
    [rightLabel setTitle:@"21+" forState:UIControlStateNormal];
    [rightLabel.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    [rightLabel setTitleColor:UIColorFromRGB(0x137b5b) forState:UIControlStateNormal];
    [rightLabel setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    rightLabel.layer.cornerRadius = 10;
    [rightLabel addTarget:self action:@selector(rightAgeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.ageSubview addSubview:rightLabel];
    
    // Create Cover Image Label
    self.coverImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.coverImageLabel setText:@"Cover Image"];
    self.coverImageLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.coverImageLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.coverImageLabel];
    
    // Create Cover Image View
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 5*LABEL_HEIGHT)];
    [self.coverImageView setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
    self.coverImageView.layer.cornerRadius = 5;
    [self.coverImageView setImage:[UIImage imageNamed:@"plus"]];
    [self.coverImageView setContentMode:UIViewContentModeScaleAspectFit];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaImageViewPressed)];
    singleTap.numberOfTapsRequired = 1;
    [self.coverImageView setUserInteractionEnabled:YES];
    [self.coverImageView.layer setMasksToBounds:YES];
    [self.coverImageView addGestureRecognizer:singleTap];
    [self.view addSubview:self.coverImageView];
    
    // Create Additional Media Label
    self.additionalMediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.additionalMediaLabel setText:@"Additional Media"];
    self.additionalMediaLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.additionalMediaLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.additionalMediaLabel];

//    // Create Additional Media Collection View
    UICollectionViewFlowLayout *mediaLayout = [[UICollectionViewFlowLayout alloc] init];
    [mediaLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.additionalMediaCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 5*LABEL_HEIGHT) collectionViewLayout:mediaLayout];
    [self.additionalMediaCollectionView registerNib:[UINib nibWithNibName:@"MediaCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MediaCollectionViewCell"];
    [self.additionalMediaCollectionView setBackgroundColor:UIColorFromRGB(BACKGROUND_GREEN)];
    [self.additionalMediaCollectionView setRestorationIdentifier:@"additionalMediaCollectionView"];
    //[self.additionalMediaCollectionView setAlwaysBounceHorizontal:YES];
    //[self.additionalMediaCollectionView setShowsHorizontalScrollIndicator:NO];
    self.additionalMediaCollectionView.layer.cornerRadius = 5;
    self.additionalMediaCollectionView.delegate = self;
    self.additionalMediaCollectionView.dataSource = self;
    [self.view addSubview:self.additionalMediaCollectionView];
    
    // Create Music Page Description Label
    self.musicPageDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2 * X_OFFSET, LABEL_HEIGHT)];
    [self.musicPageDescriptionLabel setText:@"Add Music For Your Event"];
    self.musicPageDescriptionLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.musicPageDescriptionLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.musicPageDescriptionLabel];
    
    // Create Music Note Image View
    self.musicNoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.8*X_OFFSET, [[UIScreen mainScreen] bounds].size.height, LABEL_HEIGHT, LABEL_HEIGHT)];
    [self.musicNoteImageView setImage:[UIImage imageNamed:@"note"]];
    [self.view addSubview:self.musicNoteImageView];
    
    // Create Search Music Text Field
    self.searchMusicTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width + 10, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.searchMusicTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    [self.searchMusicTextField setMinimumFontSize:30];
    [self.searchMusicTextField setAdjustsFontSizeToFitWidth:YES];
    [self.searchMusicTextField setPlaceholder:@"E.g Song or Artist..."];
    [self.searchMusicTextField addTarget:self action:@selector(displayMusicSearchView) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchMusicTextField addTarget:self action:@selector(dismissMusicSearchView) forControlEvents:UIControlEventEditingDidEnd];
//    [self.searchMusicTextField addTarget:self action:@selector(refreshResultsTableView) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.searchMusicTextField];

    // Create Music Queue Label
    self.musicQueueLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.musicQueueLabel setText:@"Your Music"];
    self.musicQueueLabel.textColor = UIColorFromRGB(LABEL_GREEN);
    [self.musicQueueLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.view addSubview:self.musicQueueLabel];
    
    // Create Music Cancel Button
    CGSize musicCancelButtonSize = [@"Cancel" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:20]}];
    self.musicCancelButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - musicCancelButtonSize.width - 15, [[UIScreen mainScreen] bounds].size.height, musicCancelButtonSize.width, LABEL_HEIGHT)];
    [self.musicCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.musicCancelButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.musicCancelButton addTarget:self action:@selector(musicCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.musicCancelButton];
    
    // Create Music Results Table View
    self.musicResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.view.frame.size.height/2.1)];
    self.musicResultsTableView.layer.cornerRadius = 5;
    self.musicResultsTableView.delegate = self;
    self.musicResultsTableView.dataSource = self;
    [self.view addSubview:self.musicResultsTableView];
    
    // Create Music Queue Collection View
    UICollectionViewFlowLayout *musicCVLayout = [[UICollectionViewFlowLayout alloc] init];
    [musicCVLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.musicQueueCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(X_OFFSET/2, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - X_OFFSET, 4*LABEL_HEIGHT) collectionViewLayout:musicCVLayout];
    [self.musicQueueCollectionView setBackgroundColor:UIColorFromRGB(BACKGROUND_GREEN)];
    self.musicQueueCollectionView.layer.cornerRadius = 5;
    [self.musicQueueCollectionView setRestorationIdentifier:@"musicCollectionView"];
    [self.musicQueueCollectionView registerNib:[UINib nibWithNibName:@"MusicQueueCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MusicQueueCollectionViewCell"];
    self.musicQueueCollectionView.delegate = self;
    self.musicQueueCollectionView.dataSource = self;
    [self.view addSubview:self.musicQueueCollectionView];
    
    // Create Next Button
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height - LABEL_HEIGHT - 4*X_OFFSET, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT)];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setBackgroundColor:UIColorFromRGB(0x137b5b)];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    self.nextButton.layer.cornerRadius = 5;
    [self.view addSubview:self.nextButton];
}

- (void) displayInitialPage {
    self.pageName = INITIAL_VIEW;
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, 3*X_OFFSET, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, self.eventTitleLabel.frame.origin.y + self.eventTitleLabel.frame.size.height - 10, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.charsLeftInTitleLabel.frame = CGRectMake(self.charsLeftInTitleLabel.frame.origin.x, self.eventTitleLabel.frame.origin.y, self.charsLeftInTitleLabel.frame.size.width, self.charsLeftInTitleLabel.frame.size.height);
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, self.eventTitleTextField.frame.origin.y + self.eventTitleTextField.frame.size.height + 30, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.searchLocationPlaceholderLabel.frame = CGRectMake(self.searchLocationPlaceholderLabel.frame.origin.x, self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height, self.searchLocationPlaceholderLabel.frame.size.width, self.searchLocationPlaceholderLabel.frame.size.height);
        self.searchLocationTextField.frame = CGRectMake(self.searchLocationTextField.frame.origin.x, self.searchLocationPlaceholderLabel.frame.origin.y, self.searchLocationTextField.frame.size.width, self.searchLocationTextField.frame.size.height);
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height + 30, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, self.datePickerLabel.frame.origin.y, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.datePickerLabel.frame.origin.y + self.datePickerLabel.frame.size.height - 5, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.pinImageView.frame = CGRectMake(self.pinImageView.frame.origin.x, self.searchLocationTextField.frame.origin.y, self.pinImageView.frame.size.width, self.pinImageView.frame.size.height);
        [self.backButton setAlpha:0];
    }];
}

- (void) dismissInitialPage {
    [UIView animateWithDuration:0.5 animations:^{
        self.eventTitleLabel.frame = CGRectMake(self.eventTitleLabel.frame.origin.x, -self.eventTitleLabel.frame.size.height, self.eventTitleLabel.frame.size.width, self.eventTitleLabel.frame.size.height);
        self.eventTitleTextField.frame = CGRectMake(self.eventTitleTextField.frame.origin.x, -self.eventTitleTextField.frame.size.height, self.eventTitleTextField.frame.size.width, self.eventTitleTextField.frame.size.height);
        self.charsLeftInTitleLabel.frame = CGRectMake(self.charsLeftInTitleLabel.frame.origin.x, -self.charsLeftInTitleLabel.frame.origin.y, self.charsLeftInTitleLabel.frame.size.width, self.charsLeftInTitleLabel.frame.size.height);
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
        self.charsLeftInTitleLabel.frame = CGRectMake(self.charsLeftInTitleLabel.frame.origin.x, -self.charsLeftInTitleLabel.frame.size.height, self.charsLeftInTitleLabel.frame.size.width, self.charsLeftInTitleLabel.frame.size.height);
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, -self.datePickerLabel.frame.size.height, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, -self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, -self.dateLabel.frame.size.height, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.searchLabel.frame = CGRectMake(self.searchLabel.frame.origin.x, X_OFFSET, self.searchLabel.frame.size.width, self.searchLabel.frame.size.height);
        self.pinImageView.frame = CGRectMake(0, X_OFFSET + self.searchLabel.frame.size.height, 1.65*LABEL_HEIGHT, 1.65*LABEL_HEIGHT);
        self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, self.pinImageView.frame.origin.y, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width), 2*LABEL_HEIGHT);
        self.searchLocationPlaceholderLabel.frame = self.searchLocationTextField.frame;
        [self.searchLocationTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:30]];
        self.locationCancelButton.frame = CGRectMake(self.locationCancelButton.frame.origin.x, X_OFFSET, self.locationCancelButton.frame.size.width, self.locationCancelButton.frame.size.height);
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
        self.charsLeftInTitleLabel.frame = CGRectMake(self.charsLeftInTitleLabel.frame.origin.x, self.eventTitleLabel.frame.origin.y, self.charsLeftInTitleLabel.frame.size.width, self.charsLeftInTitleLabel.frame.size.height);
        self.searchLabel.frame = CGRectMake(X_OFFSET, self.eventTitleTextField.frame.origin.y + self.eventTitleTextField.frame.size.height + 30, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height, self.view.frame.size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT);
        self.pinImageView.frame = CGRectMake(0.8*X_OFFSET, self.searchLocationTextField.frame.origin.y, LABEL_HEIGHT, LABEL_HEIGHT);
        self.datePickerLabel.frame = CGRectMake(self.datePickerLabel.frame.origin.x, self.searchLocationTextField.frame.origin.y + self.searchLocationTextField.frame.size.height + 30, self.datePickerLabel.frame.size.width, self.datePickerLabel.frame.size.height);
        self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.datePickerLabel.frame.origin.y + self.datePickerLabel.frame.size.height - 5, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, self.datePickerLabel.frame.origin.y, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
        self.searchResultsTableView.frame = CGRectMake(self.searchResultsTableView.frame.origin.x, self.view.frame.size.height, self.searchResultsTableView.frame.size.width, self.searchResultsTableView.frame.size.height);
        if ([self.searchLocationTextField.text isEqualToString:@""]) {
//            [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
            self.searchLocationPlaceholderLabel.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, self.searchLocationTextField.frame.origin.y + 5, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        }
        self.datePicker.alpha = 1;
    } completion:^(BOOL finished) {
        self.locationCancelButton.frame = CGRectMake(self.locationCancelButton.frame.origin.x, self.view.frame.size.height, self.locationCancelButton.frame.size.width, self.locationCancelButton.frame.size.height);
    }];
}

- (void) displayDetailsPage {
    self.pageName = DETAILS_VIEW;
    [self.vibesCollectionView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
        self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 10, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
        self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, self.descriptionTextView.frame.origin.y + self.descriptionTextView.frame.size.height + 10, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
        self.vibesCollectionView.frame = CGRectMake(self.vibesCollectionView.frame.origin.x, self.vibesLabel.frame.origin.y + self.vibesLabel.frame.size.height + 10, self.vibesCollectionView.frame.size.width, self.vibesCollectionView.frame.size.height);
        self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, self.vibesCollectionView.frame.origin.y + self.vibesCollectionView.frame.size.height + 10, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
        self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, self.ageLabel.frame.origin.y + self.ageLabel.frame.size.height + 10, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
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
            self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, self.view.frame.size.height, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, -self.descriptionLabel.frame.size.height, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height);
            self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x, -self.descriptionTextView.frame.size.height, self.descriptionTextView.frame.size.width, self.descriptionTextView.frame.size.height);
            self.vibesLabel.frame = CGRectMake(self.vibesLabel.frame.origin.x, -self.vibesLabel.frame.size.height, self.vibesLabel.frame.size.width, self.vibesLabel.frame.size.height);
            self.vibesCollectionView.frame = CGRectMake(self.vibesCollectionView.frame.origin.x, -self.vibesCollectionView.frame.size.height, self.vibesCollectionView.frame.size.width, self.vibesCollectionView.frame.size.height);
            self.ageLabel.frame = CGRectMake(self.ageLabel.frame.origin.x, -self.ageLabel.frame.size.height, self.ageLabel.frame.size.width, self.ageLabel.frame.size.height);
            self.ageSubview.frame = CGRectMake(self.ageSubview.frame.origin.x, -self.ageSubview.frame.size.height, self.ageSubview.frame.size.width, self.ageSubview.frame.size.height);
        }];
    }
}

- (void) displayMediaPage {
    self.pageName = MEDIA_VIEW;
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.additionalMediaCollectionView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        self.coverImageLabel.frame = CGRectMake(self.coverImageLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.coverImageLabel.frame.size.width, self.coverImageLabel.frame.size.height);
        self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x, self.coverImageLabel.frame.origin.y + self.coverImageLabel.frame.size.height + 10, self.coverImageView.frame.size.width, self.coverImageView.frame.size.height);
        self.additionalMediaLabel.frame = CGRectMake(self.additionalMediaLabel.frame.origin.x, self.coverImageView.frame.origin.y + self.coverImageView.frame.size.height + 10, self.additionalMediaLabel.frame.size.width, self.additionalMediaLabel.frame.size.height);
        self.additionalMediaCollectionView.frame = CGRectMake(self.additionalMediaCollectionView.frame.origin.x, self.additionalMediaLabel.frame.origin.y + self.additionalMediaLabel.frame.size.height + 10, self.additionalMediaCollectionView.frame.size.width, self.additionalMediaCollectionView.frame.size.height);
    }];
}

- (void) dismissMediaPage {
    if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.coverImageLabel.frame = CGRectMake(self.coverImageLabel.frame.origin.x, self.view.frame.size.height, self.coverImageLabel.frame.size.width, self.coverImageLabel.frame.size.height);
            self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x, self.view.frame.size.height, self.coverImageView.frame.size.width, self.coverImageView.frame.size.height);
            self.additionalMediaLabel.frame = CGRectMake(self.additionalMediaLabel.frame.origin.x, self.view.frame.size.height, self.additionalMediaLabel.frame.size.width, self.additionalMediaLabel.frame.size.height);
            self.additionalMediaCollectionView.frame = CGRectMake(self.additionalMediaCollectionView.frame.origin.x, self.view.frame.size.height, self.additionalMediaCollectionView.frame.size.width, self.additionalMediaCollectionView.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.coverImageLabel.frame = CGRectMake(self.coverImageLabel.frame.origin.x, -self.coverImageLabel.frame.size.height, self.coverImageLabel.frame.size.width, self.coverImageLabel.frame.size.height);
            self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x, -self.coverImageView.frame.size.height, self.coverImageView.frame.size.width, self.coverImageView.frame.size.height);
            self.additionalMediaLabel.frame = CGRectMake(self.additionalMediaLabel.frame.origin.x, -self.additionalMediaLabel.frame.size.height, self.additionalMediaLabel.frame.size.width, self.additionalMediaLabel.frame.size.height);
            self.additionalMediaCollectionView.frame = CGRectMake(self.additionalMediaCollectionView.frame.origin.x, -self.additionalMediaCollectionView.frame.size.height, self.additionalMediaCollectionView.frame.size.width, self.additionalMediaCollectionView.frame.size.height);
        }];
    }
}


- (void) displayMusicPage {
    self.pageName = MUSIC_VIEW;
    [self.musicQueueCollectionView reloadData];
    [self.musicResultsTableView reloadData];
    [self.nextButton setTitle:@"Publish Event" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        self.musicPageDescriptionLabel.frame = CGRectMake(self.musicPageDescriptionLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.musicPageDescriptionLabel.frame.size.width, self.musicPageDescriptionLabel.frame.size.height);
        self.musicNoteImageView.frame = CGRectMake(self.musicNoteImageView.frame.origin.x, self.musicPageDescriptionLabel.frame.origin.y + self.musicPageDescriptionLabel.frame.size.height + 10, self.musicNoteImageView.frame.size.width, self.musicNoteImageView.frame.size.height);
         self.searchMusicTextField.frame = CGRectMake(self.searchMusicTextField.frame.origin.x, self.musicNoteImageView.frame.origin.y + 5, self.searchMusicTextField.frame.size.width, self.searchMusicTextField.frame.size.height);
        self.musicQueueLabel.frame = CGRectMake(self.musicQueueLabel.frame.origin.x, self.searchMusicTextField.frame.origin.y + self.searchMusicTextField.frame.size.height + 30, self.musicQueueLabel.frame.size.width, self.musicQueueLabel.frame.size.height);
        self.musicQueueCollectionView.frame = CGRectMake(self.musicQueueCollectionView.frame.origin.x, self.musicQueueLabel.frame.origin.y + self.musicQueueLabel.frame.size.height + 10, self.musicQueueCollectionView.frame.size.width, self.musicQueueCollectionView.frame.size.height);
    }];
}

- (void) dismissMusicPage {
    if ([self.pageName isEqualToString:MEDIA_VIEW]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.musicPageDescriptionLabel.frame = CGRectMake(self.musicPageDescriptionLabel.frame.origin.x, self.view.frame.size.height, self.musicPageDescriptionLabel.frame.size.width, self.musicPageDescriptionLabel.frame.size.height);
            self.searchMusicTextField.frame = CGRectMake(self.searchMusicTextField.frame.origin.x, self.view.frame.size.height, self.searchMusicTextField.frame.size.width, self.searchMusicTextField.frame.size.height);
            self.musicQueueLabel.frame = CGRectMake(self.musicQueueLabel.frame.origin.x, self.view.frame.size.height, self.musicQueueLabel.frame.size.width, self.musicQueueLabel.frame.size.height);
            self.musicQueueCollectionView.frame = CGRectMake(self.musicQueueCollectionView.frame.origin.x, self.view.frame.size.height, self.musicQueueCollectionView.frame.size.width, self.musicQueueCollectionView.frame.size.height);
            self.musicNoteImageView.frame = CGRectMake(0.8*X_OFFSET, self.view.frame.size.height, LABEL_HEIGHT, LABEL_HEIGHT);
            self.musicResultsTableView.frame = CGRectMake(self.musicResultsTableView.frame.origin.x, self.view.frame.size.height, self.musicResultsTableView.frame.size.width, self.musicResultsTableView.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.musicPageDescriptionLabel.frame = CGRectMake(self.musicPageDescriptionLabel.frame.origin.x, -self.musicPageDescriptionLabel.frame.size.height, self.musicPageDescriptionLabel.frame.size.width, self.musicPageDescriptionLabel.frame.size.height);
            self.searchMusicTextField.frame = CGRectMake(self.searchMusicTextField.frame.origin.x, -self.searchMusicTextField.frame.size.height, self.searchMusicTextField.frame.size.width, self.searchMusicTextField.frame.size.height);
            self.musicQueueLabel.frame = CGRectMake(self.musicQueueLabel.frame.origin.x, -self.musicQueueLabel.frame.size.height, self.musicQueueLabel.frame.size.width, self.musicQueueLabel.frame.size.height);
            self.musicQueueCollectionView.frame = CGRectMake(self.musicQueueCollectionView.frame.origin.x, -self.musicQueueCollectionView.frame.size.height, self.musicQueueCollectionView.frame.size.width, self.musicQueueCollectionView.frame.size.height);
            self.musicNoteImageView.frame = CGRectMake(self.musicNoteImageView.frame.origin.x, -self.musicNoteImageView.frame.size.height, self.musicNoteImageView.frame.size.width, self.musicNoteImageView.frame.size.height);
            self.musicResultsTableView.frame = CGRectMake(self.musicResultsTableView.frame.origin.x, -self.musicResultsTableView.frame.size.height, self.musicResultsTableView.frame.size.width, self.musicResultsTableView.frame.size.height);
        }];
    }
}

- (void) displayMusicSearchView {
    [self.backButton setAlpha:0];
    [self.searchMusicTextField setPlaceholder:@""];
    [UIView animateWithDuration:0.5 animations:^{
        self.musicPageDescriptionLabel.frame = CGRectMake(self.musicPageDescriptionLabel.frame.origin.x, -self.musicPageDescriptionLabel.frame.size.height, self.musicPageDescriptionLabel.frame.size.width, self.musicPageDescriptionLabel.frame.size.height);
        self.musicNoteImageView.frame = CGRectMake(0, X_OFFSET, 1.65*LABEL_HEIGHT, 1.65*LABEL_HEIGHT);
        self.searchMusicTextField.frame = CGRectMake(self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width, self.musicNoteImageView.frame.origin.y, self.view.frame.size.width - (self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width + X_OFFSET), 2*LABEL_HEIGHT);
        [self.searchMusicTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:30]];
        self.musicQueueLabel.frame = CGRectMake(self.musicQueueLabel.frame.origin.x, -self.musicQueueLabel.frame.size.height, self.musicQueueLabel.frame.size.width, self.musicQueueLabel.frame.size.height);
        self.musicQueueCollectionView.frame = CGRectMake(self.musicQueueCollectionView.frame.origin.x, -self.musicQueueCollectionView.frame.size.height, self.musicQueueCollectionView.frame.size.width, self.musicQueueCollectionView.frame.size.height);
        self.musicCancelButton.frame = CGRectMake(self.musicCancelButton.frame.origin.x, 1.5*self.musicNoteImageView.frame.origin.y, self.musicCancelButton.frame.size.width, self.musicCancelButton.frame.size.height);
        self.musicResultsTableView.frame = CGRectMake(self.musicResultsTableView.frame.origin.x, self.searchMusicTextField.frame.origin.y + self.searchMusicTextField.frame.size.height, self.musicResultsTableView.frame.size.width, self.musicResultsTableView.frame.size.height);
    }];
}

- (void) dismissMusicSearchView {
    [self.backButton setAlpha:1];
    [UIView animateWithDuration:0.5 animations:^{
        self.musicPageDescriptionLabel.frame = CGRectMake(self.musicPageDescriptionLabel.frame.origin.x, self.backButton.frame.origin.y + self.backButton.frame.size.height + 10, self.musicPageDescriptionLabel.frame.size.width, self.musicPageDescriptionLabel.frame.size.height);
        self.musicCancelButton.frame = CGRectMake(self.musicCancelButton.frame.origin.x, -self.musicCancelButton.frame.size.height, self.musicCancelButton.frame.size.width, self.musicCancelButton.frame.size.height);
        self.musicNoteImageView.frame = CGRectMake(0.8*X_OFFSET, self.musicPageDescriptionLabel.frame.origin.y + self.musicPageDescriptionLabel.frame.size.height + 10, LABEL_HEIGHT, LABEL_HEIGHT);
        self.searchMusicTextField.frame = CGRectMake(self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width + 10, self.musicNoteImageView.frame.origin.y + 5, self.view.frame.size.width - (self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width) - X_OFFSET, LABEL_HEIGHT);
        self.musicQueueLabel.frame = CGRectMake(self.musicQueueLabel.frame.origin.x, self.searchMusicTextField.frame.origin.y + self.searchMusicTextField.frame.size.height + 30, self.musicQueueLabel.frame.size.width, self.musicQueueLabel.frame.size.height);
        self.musicQueueCollectionView.frame = CGRectMake(self.musicQueueCollectionView.frame.origin.x, self.musicQueueLabel.frame.origin.y + self.musicQueueLabel.frame.size.height + 10, self.musicQueueCollectionView.frame.size.width, self.musicQueueCollectionView.frame.size.height);
        self.musicResultsTableView.frame = CGRectMake(self.musicResultsTableView.frame.origin.x, self.view.frame.size.height, self.musicResultsTableView.frame.size.width, self.musicResultsTableView.frame.size.height);
        if ([self.searchMusicTextField.text isEqualToString:@""]) {
            [self.searchMusicTextField setPlaceholder:@"E.g Song or Artist..."];
            [self.searchMusicTextField setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
            //self.searchMusicTextField.frame = CGRectMake(self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width, self.searchMusicTextField.frame.origin.y + 5, self.view.frame.size.width - 2*X_OFFSET, LABEL_HEIGHT);
        }
    } completion:^(BOOL finished) {
        self.musicCancelButton.frame = CGRectMake(self.musicCancelButton.frame.origin.x, self.view.frame.size.height, self.musicCancelButton.frame.size.width, self.musicCancelButton.frame.size.height);
    }];
}

- (void) resetPages {
    self.eventTitleLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    self.eventTitleTextField.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 2*LABEL_HEIGHT);
    [self.eventTitleTextField setText:@""];
    
    // Create Chars Left In Title Label
    CGSize size = [[NSString stringWithFormat:@"(%d)", MAXLENGTH] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:15]}];
    self.charsLeftInTitleLabel.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - X_OFFSET - size.width, [[UIScreen mainScreen] bounds].size.height, size.width, LABEL_HEIGHT);
    [self.charsLeftInTitleLabel setText:[NSString stringWithFormat:@"(%lu)", MAXLENGTH - self.eventTitleTextField.text.length]];
    
    self.searchLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    self.pinImageView.frame = CGRectMake(0.8*X_OFFSET, [[UIScreen mainScreen] bounds].size.height, LABEL_HEIGHT, LABEL_HEIGHT);
    
    self.searchLocationPlaceholderLabel.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + X_OFFSET), LABEL_HEIGHT);
    [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
    
    self.datePickerLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    self.datePicker.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 150);
    [self.datePicker setMinimumDate: [NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yy, h:mm a"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    size = [[NSString stringWithFormat:@"%@", date] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:15]}];
    self.dateLabel.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - X_OFFSET - size.width, [[UIScreen mainScreen] bounds].size.height, size.width, LABEL_HEIGHT);
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", date]];
    
    self.searchLocationTextField.frame = CGRectMake(self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - (self.pinImageView.frame.origin.x + self.pinImageView.frame.size.width + 10) - X_OFFSET, LABEL_HEIGHT);
    [self.searchLocationTextField setText:@""];
    
    CGSize locationCancelButtonSize = [@"Cancel" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:20]}];
    self.locationCancelButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - locationCancelButtonSize.width - 15, [[UIScreen mainScreen] bounds].size.height, locationCancelButtonSize.width, LABEL_HEIGHT);
    
    self.nextButton.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height - LABEL_HEIGHT - 4*X_OFFSET, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    
    self.searchResultsTableView.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.view.frame.size.height/2.1);
    
    self.descriptionLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    self.descriptionTextView.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 3*LABEL_HEIGHT);
    
    self.vibesLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    self.vibesCollectionView.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 1.3*LABEL_HEIGHT);
    
    self.ageLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    self.ageSubview.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, 3*LABEL_HEIGHT);
    
    self.coverImageLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    [self.coverImageView setImage:[UIImage imageNamed:@"plus"]];
    self.coverImageView.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.coverImageView.frame.size.height);
    
    self.additionalMediaLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.additionalMediaLabel.frame.size.height);
    
    self.additionalMediaCollectionView.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.additionalMediaCollectionView.frame.size.height);
    
    self.musicPageDescriptionLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2 * X_OFFSET, LABEL_HEIGHT);
    
    self.musicNoteImageView.frame = CGRectMake(0.8*X_OFFSET, [[UIScreen mainScreen] bounds].size.height, LABEL_HEIGHT, LABEL_HEIGHT);
    
    self.searchMusicTextField.frame = CGRectMake(self.musicNoteImageView.frame.origin.x + self.musicNoteImageView.frame.size.width + 10, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    [self.searchLocationTextField setText:@""];
    
    self.musicQueueLabel.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, LABEL_HEIGHT);
    
    CGSize musicCancelButtonSize = [@"Cancel" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:20]}];
    self.musicCancelButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - musicCancelButtonSize.width - 15, [[UIScreen mainScreen] bounds].size.height, musicCancelButtonSize.width, LABEL_HEIGHT);
    
    self.musicResultsTableView.frame = CGRectMake(X_OFFSET, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 2*X_OFFSET, self.view.frame.size.height/2.1);
    
    self.musicQueueCollectionView.frame = CGRectMake(X_OFFSET/2, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - X_OFFSET, 4*LABEL_HEIGHT);
    
    self.vibesSet = [[NSMutableSet alloc] init];
    NSLog(@"HEYAA");
    [self createAdditionalImagesArray];
    NSLog(@"HEYAA");
    [self createSongsArray];
    NSLog(@"HEYAA");
}

- (void) nextButtonPressed {
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        if ([self.eventTitleTextField.text isEqualToString:@""]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Required Field Is Empty" message:@"Please give your event a title" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else if ([self.searchLocationTextField.text isEqualToString:@""]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Required Field Is Empty" message:@"Please give your event a location" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self dismissInitialPage];
            [self displayDetailsPage];
        }
    } else if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        [self dismissDetailsPage];
        [self displayMediaPage];
    } else if ([self.pageName isEqualToString:MEDIA_VIEW]) {
        [self dismissMediaPage];
        [self displayMusicPage];
    } else if ([self.pageName isEqualToString:MUSIC_VIEW]) {
        [self publishEvent];
        [self dismissMusicPage];
        [self resetPages];
        [self displayInitialPage];
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
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
    else if ([self.pageName isEqualToString:MUSIC_VIEW]) {
        [self displayMediaPage];
        [self dismissMusicPage];
    }
}

- (void) mediaImageViewPressed {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if (self.isCoverImage) {
        [self.coverImageView setImage:editedImage];
        long width = editedImage.size.width*self.coverImageView.frame.size.height/self.coverImageView.image.size.height;
        self.coverImageView.frame = CGRectMake(self.coverImageView.frame.origin.x + (self.coverImageView.frame.size.width - width)/2, self.coverImageView.frame.origin.y, width, self.coverImageView.frame.size.height);
    } else {
        [self.additionalImages insertObject:editedImage atIndex:1];
        [self.additionalMediaCollectionView reloadData];
    }
    self.isCoverImage = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publishEvent {
    [self.additionalImages removeObjectAtIndex:0]; // Remove the plus image
    [self.additionalImages addObject:self.coverImageView.image]; // Add the main image
    NSMutableArray *registeredUsers = [[NSMutableArray alloc] init];
    [registeredUsers addObject:[FIRAuth auth].currentUser.uid];
    NSDictionary *eventDict = @{
        @"Created By": [[[UserInSession shared] sharedUser] nameString],
        @"Event Name": self.eventTitleTextField.text,
        @"Attendance": @(1),
        @"ImageURL": @"https://bit.ly/2SYp8Za",
        @"Description": self.descriptionTextView.text,
        @"Age Restriction": @(self.ageRestriction),
        @"Location": [NSString stringWithFormat:@"%.5f %.5f", self.coordinates.latitude, self.coordinates.longitude],
        @"Vibes": [self.vibesSet allObjects],
        @"Media": self.additionalImages,
        @"Music Queue": self.queuedUpSongsArray,
        @"Start Date": self.eventStartDateString,
        @"Registered Users": @[[FIRAuth auth].currentUser.uid],
        @"Number of Additional Media Files": @(self.additionalImages.count - 1)
    };
    Event *event = [[Event alloc] initWithDictionary:eventDict];
    [[DataHandling shared] addEventToDatabase:event];
    [self.delegate refreshAfterEventCreation];
}

- (void) locationCancelButtonPressed {
    [self.searchLocationTextField setText:@""];
    [self dismissKeyboard];
    [self.searchLocationPlaceholderLabel setText:@"City, street, museum..."];
}

- (void) musicCancelButtonPressed {
    [self dismissKeyboard];
    [self.searchMusicTextField setText:@""];
}

- (void) leftAgeButtonPressed {
    [UIView animateWithDuration:1 animations:^{
        if (self.leftAgeRestriction.value == 100) {
            self.leftAgeRestriction.value = 0;
            self.ageRestriction = 0;
        } else {
            self.leftAgeRestriction.value = 100;
            self.rightAgeRestriction.value = 0;
            self.ageRestriction = 18;
        }
    }];
}

- (void) rightAgeButtonPressed {
    [UIView animateWithDuration:1 animations:^{
        if (self.rightAgeRestriction.value == 100) {
            self.rightAgeRestriction.value = 0;
            self.ageRestriction = 0;
        } else {
            self.rightAgeRestriction.value = 100;
            self.leftAgeRestriction.value = 0;
            self.ageRestriction = 21;
        }
    }];
}

- (void) pickerValueChanged {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.eventStartDateString = [dateFormatter stringFromDate:self.datePicker.date];
    NSLog(@"EVENT START DATE: %@", self.eventStartDateString);
    CGSize size = [self.eventStartDateString sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:15]}];
    self.dateLabel.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - X_OFFSET - size.width, self.datePickerLabel.frame.origin.y, size.width, LABEL_HEIGHT);
    self.dateLabel.text = self.eventStartDateString;
}

//- (void) pickerValueChanged {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//    NSString *strDate = [dateFormatter stringFromDate:self.datePicker.date];
//    CGSize size = [strDate sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamRounded-Bold" size:15]}];
//    self.dateLabel.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - X_OFFSET - size.width, self.datePickerLabel.frame.origin.y, size.width, LABEL_HEIGHT);
//    self.dateLabel.text = strDate;
//}

- (void) refreshResultsTableView {
    NSString *coordinates = @"37.77,-122.41";
    NSString *query = self.searchLocationTextField.text;
    NSString *CLIENT_ID = @"3NZPO204JPDCJW0XJWY5AFCWCLXNZWDNIOHTQYHHOP0ARXRI";
    NSString *CLIENT_SECRET = @"ASWMRXJPXFIX0D3NWMOWSVHKID52USWCSA402SQLWD0CQHFS";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSString *URLString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/suggestcompletion?ll=%@&query=%@&client_id=%@&client_secret=%@&v=%@", coordinates, query, CLIENT_ID, CLIENT_SECRET, date];
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
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", [(SearchResult *)self.recentSearchResults[indexPath.row] getName]]];
        return cell;
    } else if ([self.pageName isEqualToString:MUSIC_VIEW]) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", ((Song *)self.songsArray[indexPath.row]).title]];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        return self.recentSearchResults.count;
    } else if ([self.pageName isEqualToString:MUSIC_VIEW]) {
        return self.songsArray.count;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
    if ([self.pageName isEqualToString:INITIAL_VIEW]) {
        [self.searchLocationTextField setText:[self.recentSearchResults[indexPath.row] getName]];
        self.coordinates = [self.recentSearchResults[indexPath.row] getCoordinates];
    } else if ([self.pageName isEqualToString:MUSIC_VIEW]) {
        Song *song = self.songsArray[indexPath.row];
        [self.queuedUpSongsArray insertObject:song atIndex:self.queuedUpSongsArray.count - 1];
        [self.musicQueueCollectionView reloadData];
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.pageName isEqualToString:DETAILS_VIEW] && [collectionView.restorationIdentifier isEqualToString:@"vibesCollectionView"]) {
        CustomCollectionViewCell *cell = [self.vibesCollectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionViewCell" forIndexPath:indexPath];
        [cell setLabelText:self.vibesArray[indexPath.item]];
        [cell setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
        return cell;
    } else if ([self.pageName isEqualToString:MUSIC_VIEW] && [collectionView.restorationIdentifier isEqualToString:@"musicCollectionView"]) {
        NSLog(@"1. ROW: %lu", indexPath.row);
        NSLog(@"%@", collectionView);
        MusicQueueCollectionViewCell *cell = [self.musicQueueCollectionView dequeueReusableCellWithReuseIdentifier:@"MusicQueueCollectionViewCell" forIndexPath:indexPath];
        NSLog(@"2. ROW: %lu", indexPath.row);
        [cell initWithSong:self.queuedUpSongsArray[indexPath.row]];
        NSLog(@"3. ROW: %lu", indexPath.row);
        cell.layer.cornerRadius = 5;
        [cell.nameLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:15]];
        [cell.artistNameLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:10]];
        return cell;
    } else if ([self.pageName isEqualToString:MEDIA_VIEW]  && [collectionView.restorationIdentifier isEqualToString:@"additionalMediaCollectionView"]) {
        MediaCollectionViewCell *cell = [self.additionalMediaCollectionView dequeueReusableCellWithReuseIdentifier:@"MediaCollectionViewCell" forIndexPath:indexPath];
        [cell.imageView setImage:self.additionalImages[indexPath.row]];
        cell.layer.cornerRadius = 5;
        return cell;
    } else {
        UICollectionViewCell *cell = [self.vibesCollectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        NSLog(@"COUNT: %lu", self.vibesArray.count);
        return self.vibesArray.count;
    } else if ([self.pageName isEqualToString:MUSIC_VIEW]) {
        NSLog(@"COUNT: %lu", self.queuedUpSongsArray.count);
        return self.queuedUpSongsArray.count;
    } else if ([self.pageName isEqualToString:MEDIA_VIEW]) {
        NSLog(@"COUNT: %lu", self.additionalImages.count);
        return self.additionalImages.count;
    } else {
        NSLog(@"%i", 1);
        return 1;
    }
}
    
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.pageName isEqualToString:DETAILS_VIEW] && [collectionView.restorationIdentifier isEqualToString:@"vibesCollectionView"]) {
        CustomCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"CustomCollectionViewCell" owner:self options:nil].firstObject;
        [cell setLabelText:self.vibesArray[indexPath.row]];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return CGSizeMake(size.width, 30);
    } else if ([self.pageName isEqualToString:MUSIC_VIEW] && [collectionView.restorationIdentifier isEqualToString:@"musicCollectionView"]) {
        return CGSizeMake(90, 120);
    } else if ([self.pageName isEqualToString:MEDIA_VIEW] && [collectionView.restorationIdentifier isEqualToString:@"additionalMediaCollectionView"]) {
        return CGSizeMake(2*self.additionalMediaCollectionView.frame.size.height/3, 2*self.additionalMediaCollectionView.frame.size.height/3);
    } else {
        return CGSizeMake(90, 120);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.3 animations:^{
            cell.frame = CGRectMake(cell.frame.origin.x - 5, cell.frame.origin.y - 2.5, cell.frame.size.width + 10, cell.frame.size.height + 5);
        }];
        [cell setBackgroundColor:UIColorFromRGB(DARK_GREEN)];
        [cell.titleLabel setTextColor:UIColorFromRGB(0xffffff)];
        [self.vibesSet addObject:cell.titleLabel.text];
    } else if ([self.pageName isEqualToString:MUSIC_VIEW] && indexPath.row == self.queuedUpSongsArray.count - 1) {
        [self.searchMusicTextField becomeFirstResponder];
    } else if ([self.pageName isEqualToString:MEDIA_VIEW] && indexPath.row == self.queuedUpSongsArray.count - 1) {
        self.isCoverImage = NO;
        [self mediaImageViewPressed];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.pageName isEqualToString:DETAILS_VIEW]) {
        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.vibesCollectionView cellForItemAtIndexPath:indexPath];
        [UIView animateWithDuration:0.3 animations:^{
            cell.frame = CGRectMake(cell.frame.origin.x + 5, cell.frame.origin.y + 2.5, cell.frame.size.width - 10, cell.frame.size.height - 5);
        }];
        [cell setBackgroundColor:UIColorFromRGB(LIGHT_GREEN)];
        [cell.titleLabel setTextColor:UIColorFromRGB(0x000000)];
        [self.vibesSet removeObject:cell.titleLabel.text];
    }
}

- (BOOL) textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAXLENGTH || returnKey;
}

- (void) textFieldDidChange {
    [self.charsLeftInTitleLabel setText:[NSString stringWithFormat:@"(%lu)", MAXLENGTH - self.eventTitleTextField.text.length]];
}

@end
