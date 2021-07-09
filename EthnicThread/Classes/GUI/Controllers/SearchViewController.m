//
//  SearchViewController.m
//  EthnicThread
//
//  Created by Katori on 12/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "LocationSearching.h"
#import "AnimatedTransitioning.h"
#import "SellerNamesViewController.h"
#import "AutocompleteTextField.h"
#import "SelectionsView.h"
#import "LocationManager.h"
#import "CountriesViewController.h"
#import "SizeButton.h"

@interface SearchViewController () <UITextFieldDelegate, SlideNavigationControllerDelegate, UIViewControllerTransitioningDelegate, LocationSearchingDelegate, SelerNamesViewControllerDelegate, AutocompleteDataSource, SelectionsViewDelegate, CountriesViewControllerDelegate> {
    NSInteger pickerSelectedIndex;
    BOOL shouldReloadLocation;
}

@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightSearchButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightSelectionView;
@property (strong, nonatomic) IBOutlet UIView *vBottomCountry;
@property (strong, nonatomic) IBOutlet UIView *vBottomAddress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lcBottomAddressContainer;
@property (strong, nonatomic) IBOutlet UIView *vAddressContainer;

@property (weak, nonatomic) IBOutlet UITextField    *tfAddress;
@property (weak, nonatomic) IBOutlet AutocompleteTextField    *tfCity;
@property (weak, nonatomic) IBOutlet AutocompleteTextField    *tfState;
@property (nonatomic, assign) IBOutlet UIButton             *btnCountry;
@property (weak, nonatomic) IBOutlet SizeButton       *btnSizeS;
@property (weak, nonatomic) IBOutlet SizeButton       *btnSizeM;
@property (weak, nonatomic) IBOutlet SizeButton       *btnSizeL;
@property (weak, nonatomic) IBOutlet SizeButton       *btnSizeXL;
@property (weak, nonatomic) IBOutlet UITextField    *tfKeywords;
@property (weak, nonatomic) IBOutlet UIButton       *btnSellerName;
@property (weak, nonatomic) IBOutlet UIButton       *btnLimitFollowingSellers;
@property (weak, nonatomic) IBOutlet UIButton       *btnLimitAvailableItems;
@property (weak, nonatomic) IBOutlet UIButton       *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton       *btnDistance;
@property (nonatomic, assign) IBOutlet UIButton     *btnNew;
@property (nonatomic, assign) IBOutlet UIButton     *btnLikeNew;
@property (nonatomic, assign) IBOutlet UIView       *vSelection;
@property (nonatomic, assign) IBOutlet UIView               *vSizeView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightSizeView;
@property (nonatomic, assign) IBOutlet UIView               *vConditionView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightConditionView;
@property (nonatomic, assign) IBOutlet UILabel      *lblRequiredCity;
@property (nonatomic, assign) IBOutlet UILabel      *lblRequiredState;
@property (nonatomic, assign) IBOutlet UILabel      *lblRequiredCountry;
@property (nonatomic, assign) IBOutlet UIView       *vTopKeywordLine;

@property (nonatomic, strong) NSMutableArray        *distanceArray;
@property (nonatomic, strong) CLLocation            *currentLocation;
@property (strong, nonatomic) LocationSearching     *locationSearch;
@property (nonatomic, assign) id <NSObject>         notificationObserver;
@property (nonatomic, strong) NSString              *selerName;
@property (nonatomic, strong) Addresses             *addresses;
@property (nonatomic, strong) SelectionsView        *selectionView;
@property (nonatomic, strong) NSTimer               *timer;
@property (nonatomic, strong) NSMutableArray        *selectedPurchases;
@property (nonatomic, assign) IBOutlet UIButton             *btnForSale;
@property (nonatomic, assign) IBOutlet UIButton             *btnForRent;
@property (nonatomic, assign) IBOutlet UIButton             *btnForExchange;
@property (nonatomic, assign) IBOutlet UIButton             *btnJustFun;
@property (nonatomic, assign) BOOL                  allowMultiSelection;
@end

@implementation SearchViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initVariables {
    [super initVariables];
    self.addresses = [[AppManager sharedInstance] getAddresses];
    self.locationSearch = [[LocationSearching alloc] init];
    self.locationSearch.delegate = self;
    self.distanceArray = [NSMutableArray arrayWithObjects:@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @(15), @(20), @(30), @(40), @(50), @(100), @(0), nil];
    pickerSelectedIndex = [self.distanceArray indexOfObject:@(100)];
    self.allowMultiSelection = YES;
    self.selectedPurchases = [NSMutableArray array];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"search", @"") andTextColor:BLACK_COLOR_TEXT];
    if (self.canBackToMainMenu) {
        [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:CGRectMake(15, 5, 40, 50)];
    }
    else {
        [self setLeftNavigationItem:@""
                       andTextColor:nil
                     andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                           andFrame:CGRectMake(0, 0, 40, 35)];
    }
    
    self.btnDistance.layer.cornerRadius = 3;
    self.btnDistance.layer.masksToBounds = YES;
    [self.btnDistance setEnabled:self.currentLocation != nil];
    [self.btnCountry setSelected:YES];
    UIColor *color = [UIColor lightGrayColor];
    [self.btnCountry setTitleColor:color forState:UIControlStateSelected];
    
    self.selectionView = [[[UINib nibWithNibName:NSStringFromClass([SelectionsView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.selectionView.delegate = self;
    self.selectionView.allowMultiSelection = YES;
    [self.selectionView setAllTags:[[AppManager sharedInstance] getTags:self.isService]];
    self.selectionView.isService = self.isService;
    [self.selectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vSelection addSubview:self.selectionView];
    [self.selectionView configureViewForSearch];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1.0];
    [self.vSelection addConstraint:lc];
    
    [self.btnSizeS setTitle:SIZE_S forState:UIControlStateNormal];
    [self.btnSizeS setTitle:SIZE_S forState:UIControlStateSelected];
    [self.btnSizeS setSelected:NO];
    [self.btnSizeM setTitle:SIZE_M forState:UIControlStateNormal];
    [self.btnSizeM setTitle:SIZE_M forState:UIControlStateSelected];
    [self.btnSizeM setSelected:NO];
    [self.btnSizeL setTitle:SIZE_L forState:UIControlStateNormal];
    [self.btnSizeL setTitle:SIZE_L forState:UIControlStateSelected];
    [self.btnSizeL setSelected:NO];
    [self.btnSizeXL setTitle:SIZE_XL forState:UIControlStateNormal];
    [self.btnSizeXL setTitle:SIZE_XL forState:UIControlStateSelected];
    [self.btnSizeXL setSelected:NO];
    
    [self.btnNew setTitle:NSLocalizedString(@"text_new", @"") forState:UIControlStateNormal];
    [self.btnLikeNew setTitle:NSLocalizedString(@"text_likenew", @"") forState:UIControlStateNormal];
    
    NSNumber *distance = [self.distanceArray objectAtIndex:pickerSelectedIndex];
    [self.btnDistance setTitle:[self convertDisplayedTextFromDistance:distance] forState:UIControlStateNormal];
    [self updateCurrentLocation:nil];
    [[LocationManager sharedInstance] updateLocation];
    
    [[AppManager sharedInstance] updateTags:YES andListener:self];
    
    self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *noti) {
                                                      if (shouldReloadLocation) {
                                                          [self startSearchByAddress];
                                                      }
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:UPDATE_CURRENT_LOCATION object:nil];
    
    [self shouldHideAddressCountry:YES];
}

- (void)updateViewConstraints {    
    if ([self.vSelection.constraints containsObject:self.lcHeightSelectionView]) {
        [self.vSelection removeConstraint:self.lcHeightSelectionView];
        self.lcHeightSelectionView = nil;
    }
    
    if (self.isService) {
        self.lcHeightSizeView.constant = 0;
        [self.vSizeView setHidden:YES];
        [self.vTopKeywordLine setHidden:YES];
        self.lcHeightConditionView.constant = 0;
        [self.vConditionView setHidden:YES];
    }
    else {
        self.lcHeightSizeView.constant = 40;
        [self.vSizeView setHidden:NO];
        [self.vTopKeywordLine setHidden:NO];
        self.lcHeightConditionView.constant = 60;
        [self.vConditionView setHidden:NO];
    }
    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [self.locationSearch stopAndQuit];
}

- (void)shouldHideAddressCountry:(BOOL)shouldHide {
    [self.vAddressContainer removeConstraint:self.lcBottomAddressContainer];
    if (shouldHide) {
        self.lcBottomAddressContainer = [self.vAddressContainer addBottomConstraintForItem:self.vBottomAddress bottom:0];
    } else {
        self.lcBottomAddressContainer = [self.vAddressContainer addBottomConstraintForItem:self.vBottomCountry bottom:5];
    }
}

- (IBAction)didBeginEditTfAddress:(id)sender {
    [self shouldHideAddressCountry:NO];
}

- (void)updateCurrentLocation:(NSNotification *)noti {
    if (self.currentLocation == nil) {
        LocationManager *lm = [LocationManager sharedInstance];
        self.tfAddress.text = [lm getCurrentAddress];
        self.tfCity.text = [lm getCurrentCity];
        self.tfState.text = [lm getCurrentState];
        [self.btnCountry setTitle:[lm getCurrentCountry] forState:UIControlStateNormal];
        [self.btnCountry setSelected:([self.btnCountry titleForState:UIControlStateNormal] == 0)];
        self.currentLocation = [lm getCurrentLocation];
        [self.btnDistance setEnabled:self.currentLocation != nil];
    }
    [self checkEnabeSearchButtonByCity:self.tfCity.text state:self.tfState.text country:[self.btnCountry titleForState:UIControlStateNormal]];
}

- (void)willOpenLeftMenu {
    [super willOpenLeftMenu];
    [self.tfAddress resignFirstResponder];
    [self.tfCity resignFirstResponder];
    [self.tfState resignFirstResponder];
    [self.tfKeywords resignFirstResponder];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    if (self.canBackToMainMenu) {
        [self handleTouchToMainMenuButton];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)checkEnabeSearchButtonByCity:(NSString *)city state:(NSString *)state country:(NSString *)country {
    NSInteger distanceMiles = [[self.distanceArray objectAtIndex:pickerSelectedIndex] integerValue];
    if (distanceMiles == ANYWHERE_EQUAL_DISTANCE) {
        [self.lblRequiredCity setHidden:YES];
        [self.lblRequiredState setHidden:YES];
        [self.lblRequiredCountry setHidden:([self.btnCountry titleForState:UIControlStateNormal].length > 0)];
        [self.btnSearch setEnabled:([self.btnCountry titleForState:UIControlStateNormal].length > 0)];
    }
    else {
        [self.btnSearch setEnabled:(city.length > 0 && state.length > 0 && country.length > 0)];
        [self.lblRequiredCity setHidden:(city.length > 0)];
        [self.lblRequiredState setHidden:(state.length > 0)];
        [self.lblRequiredCountry setHidden:(country.length > 0)];
    }
}

- (NSString *)convertDisplayedTextFromDistance:(NSNumber *)distance {
    if ([distance integerValue] == ANYWHERE_EQUAL_DISTANCE) {
        return NSLocalizedString(@"anywhere", @"");
    }
    else if ([distance integerValue] == 1) {
        return [NSString stringWithFormat:@"%@ Mile", [distance description]];
    }
    else {
        return [NSString stringWithFormat:@"%@ Miles", [distance description]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.tfCity resignFirstResponder];
    [self.tfKeywords resignFirstResponder];
    [self.tfState resignFirstResponder];
    [self.tfAddress resignFirstResponder];
}

- (IBAction)handleBtnSizeSPressed:(id)sender {
    self.btnSizeS.selected = !self.btnSizeS.selected;
}
- (IBAction)handleBtnSizeMPressed:(id)sender {
    self.btnSizeM.selected = !self.btnSizeM.selected;
}
- (IBAction)handleBtnSizeLPressed:(id)sender {
    self.btnSizeL.selected = !self.btnSizeL.selected;
}
- (IBAction)handleBtnSizeXLPressed:(id)sender {
    self.btnSizeXL.selected = !self.btnSizeXL.selected;
}
- (IBAction)handleBtnLimitPressed:(id)sender {
    self.btnLimitFollowingSellers.selected = !self.btnLimitFollowingSellers.selected;
}
- (IBAction)handleLimitAvailableItem:(id)sender {
    self.btnLimitAvailableItems.selected = !self.btnLimitAvailableItems.selected;
}

- (void)updatePurchases:(UIButton *)button {
    [self.selectedPurchases removeAllObjects];
    if (self.btnForSale.selected) {
        [self.selectedPurchases addObject:PURCHASES_SALE];
    }
    if (self.btnForRent.selected) {
        [self.selectedPurchases addObject:PURCHASES_RENT];
    }
    if (self.btnForExchange.selected) {
        [self.selectedPurchases addObject:PURCHASES_EXCHANGE];
    }
    if (self.btnJustFun.selected) {
        [self.selectedPurchases addObject:PURCHASES_FUN];
    }
    
    NSString *purchase = @"";
    if (self.btnForSale == button) purchase = PURCHASES_SALE;
    if (self.btnForRent == button) purchase = PURCHASES_RENT;
    if (self.btnForExchange == button) purchase = PURCHASES_EXCHANGE;
    if (self.btnJustFun == button) purchase = PURCHASES_FUN;
}

- (IBAction)handleForSaleButton:(id)sender {
    self.btnForSale.selected = !self.btnForSale.selected;
    if (!self.allowMultiSelection) {
        if (self.btnForSale.selected || self.btnForRent.selected || self.btnForExchange.selected) {
            [self.btnJustFun setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleForRentButton:(id)sender {
    self.btnForRent.selected = !self.btnForRent.selected;
    if (!self.allowMultiSelection) {
        if (self.btnForSale.selected || self.btnForRent.selected || self.btnForExchange.selected) {
            [self.btnJustFun setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleForExchangeButton:(id)sender {
    self.btnForExchange.selected = !self.btnForExchange.selected;
    if (!self.allowMultiSelection) {
        if (self.btnForSale.selected || self.btnForRent.selected || self.btnForExchange.selected) {
            [self.btnJustFun setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleJustFunButton:(id)sender {
    self.btnJustFun.selected = !self.btnJustFun.selected;
    if (!self.allowMultiSelection) {
        if (self.btnJustFun.selected) {
            [self.btnForSale setSelected:NO];
            [self.btnForRent setSelected:NO];
            [self.btnForExchange setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}


- (IBAction)handleSelerNameButton:(id)sender {
    SellerNamesViewController *vc = [[SellerNamesViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)handleBtnSearchPressed:(id)sender {
    [self.tfCity resignFirstResponder];
    [self.tfKeywords resignFirstResponder];
    [self.tfState resignFirstResponder];
    [self.tfAddress resignFirstResponder];
    
    SearchCriteria *criteria = [self makeSearchCriteria];
    SearchResultViewController *vc = [[SearchResultViewController alloc] init];
    vc.criteria = criteria;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)handleBtnDistancePressed:(id)sender {
    [self shouldHideAddressCountry:NO];
    PickerViewController *pickerVC = [[PickerViewController alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSNumber *distance in self.distanceArray) {
        [array addObject:[self convertDisplayedTextFromDistance:distance]];
    }
    [pickerVC setPickerArray:array];
    [pickerVC.lblUnit setHidden:YES];
    [pickerVC setSelectedIndex:pickerSelectedIndex];
    [pickerVC setPickerDelegate:self];
    pickerVC.transitioningDelegate = self;
    pickerVC.modalPresentationStyle = UIModalPresentationCustom;
    [pickerVC.view setFrame:self.view.frame];
    [self presentViewController:pickerVC animated:YES completion:nil];
}

- (IBAction)handleNewButton:(id)sender {
    self.btnNew.selected = !self.btnNew.selected;
    self.btnLikeNew.selected = NO;
}

- (IBAction)handleLikeNewButton:(id)sender {
    self.btnLikeNew.selected = !self.btnLikeNew.selected;
    self.btnNew.selected = NO;
}

- (IBAction)handleCountryButton:(id)sender {
    CountriesViewController *vc = [[CountriesViewController alloc] init];
    vc.countries = [self.addresses getCountries];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (SearchCriteria *)makeSearchCriteria {
    SearchCriteria *criteria = [[SearchCriteria alloc] init];
    if (self.isService) {
        criteria.category = @"service";
    }
    else {
        criteria.category = @"listed";
        
        NSString *size = @"";
        if (self.btnSizeS.selected) {
            size = [size stringByAppendingFormat:@"%@", SIZE_S];
        }
        if (self.btnSizeM.selected) {
            size = [size stringByAppendingFormat:@",%@", SIZE_M];
        }
        if (self.btnSizeL.selected) {
            size = [size stringByAppendingFormat:@",%@", SIZE_L];
        }
        if (self.btnSizeXL.selected) {
            size = [size stringByAppendingFormat:@",%@", SIZE_XL];
        }
        size = [size stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        criteria.size = size;
        
        NSString *condition = @"";
        condition = self.btnNew.selected ? CONDITION_NEW : @"";
        condition = self.btnLikeNew.selected ? CONDITION_LIKENEW : condition;
        criteria.condition = condition;
        
//        criteria.gender = [self.selectionView.selectedGenders componentsJoinedByString:@","];
        criteria.gender = [[self.selectionView getSelectedGendersFromTags] componentsJoinedByString:@","];
        criteria.purchases = [self.selectedPurchases componentsJoinedByString:@","];
    }
    criteria.tags = [self.selectionView.selectedTags componentsJoinedByString:@","];
    criteria.country = [self.btnCountry titleForState:UIControlStateNormal];
    criteria.city = self.tfCity.text;
    criteria.state = self.tfState.text;
    criteria.keywords = self.tfKeywords.text;
    criteria.sellerName = self.selerName;
    criteria.limitFollow = self.btnLimitFollowingSellers.selected;
    criteria.limitAvailable = self.btnLimitAvailableItems.selected;
    criteria.radius = [[self.distanceArray objectAtIndex:pickerSelectedIndex] integerValue];
    criteria.location = self.currentLocation;
   
    return criteria;
}

- (NSArray *)getGenderTags {
    NSArray *tags = self.selectionView.selectedTags;
    NSMutableArray *selectedGender = [NSMutableArray array];
    for (NSString *tagValue in tags) {
        NSDictionary *tagDict = [[AppManager sharedInstance] getTags:NO];
        [tagDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            for (NSString *value in obj) {
                if ([tagValue isEqualToString:value]) {
                    [selectedGender addObject:key];
                }
            }
        }];
    }
    
    return selectedGender;
}

- (BOOL)isTagInArray:(NSArray *)tagArray tagValue:(NSString *)tagValue {
    for (NSString *tagKey in tagArray) {
        if ([tagKey isEqualToString:tagValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)timerTick:(NSTimer *)timer {
    [self startSearchByAddress];
}

- (void)startSearchByAddress {
    NSString *locationString = [Utils generateLocationStringFrom:self.tfAddress.text
                                                            city:self.tfCity.text
                                                           state:self.tfState.text
                                                         country:[self.btnCountry titleForState:UIControlStateNormal]];
    if (locationString.length > 0) {
        [self.locationSearch startSearchByAddress:locationString];
    }
}

#pragma mark - LocationSearchingDelegate
- (void)errorLocationSearchingMessage:(NSString *)message {
    [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"") message:message];
}

- (void)locationServicesEnabled:(BOOL)enabled {
    shouldReloadLocation = !enabled;
    if (!enabled) {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                       message:NSLocalizedString(@"alert_please_enable_location_service", @"")];
    }
}

- (void)searchedLocation:(MKLocalSearchResponse *)response andAddressText:(NSString *)addressString {
    
}

- (void)didUpdateLocation:(CLLocation *)location {
    self.currentLocation = location;
    [self.btnDistance setEnabled:self.currentLocation != nil];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState) {
        [self startSearchByAddress];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([Utils checkEmojiLanguage:[[textField textInputMode] primaryLanguage]]) {
        return NO;
    }
    
    if (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerTick:) userInfo:nil repeats:NO];

        NSMutableString *text = [NSMutableString stringWithString:textField.text];
        [text replaceCharactersInRange:range withString:string];
        if (textField == self.tfCity) {
            [self checkEnabeSearchButtonByCity:text state:self.tfState.text country:[self.btnCountry titleForState:UIControlStateNormal]];
        }
        else if (textField == self.tfState) {
            [self checkEnabeSearchButtonByCity:self.tfCity.text state:text country:[self.btnCountry titleForState:UIControlStateNormal]];
        }
    }
    return YES;
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return self.canBackToMainMenu;
}

#pragma mark - PickerViewControllerDelegate
- (void)selectedPickerAtIndex:(NSInteger)index hasValue:(id)value {
    pickerSelectedIndex = index;
    NSInteger distanceMiles = [[self.distanceArray objectAtIndex:pickerSelectedIndex] integerValue];
    if (distanceMiles == ANYWHERE_EQUAL_DISTANCE) {
        [self.btnDistance setTitle:NSLocalizedString(@"anywhere", @"") forState:UIControlStateNormal];
    }
    else {
        [self.btnDistance setTitle:value forState:UIControlStateNormal];
    }
    [self checkEnabeSearchButtonByCity:self.tfCity.text state:self.tfState.text country:[self.btnCountry titleForState:UIControlStateNormal]];
    [self.view updateConstraints];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

#pragma mark - SelerNamesViewControllerDelegate
- (void)searchSelerNameResult:(BasicInfoUserModel *)searchUser {
    self.selerName = (searchUser.isAnySeller) ? @"" : [searchUser getFullName];
    [self.btnSellerName setTitle:[searchUser getDisplayName] forState:UIControlStateNormal];
}

#pragma mark - CountriesViewControllerDelegate
- (void)searchCountryResult:(NSString *)country {
    [self.btnCountry setTitle:country forState:UIControlStateNormal];
    [self.btnCountry setSelected:(country == 0)];
    [self.lblRequiredCountry setHidden:(country.length > 0)];
    [self startSearchByAddress];
    [self checkEnabeSearchButtonByCity:self.tfCity.text state:self.tfState.text country:country];
}

#pragma mark - AutocompleteDataSource
- (NSArray *)resourceForTextField:(AutocompleteTextField *)textField {
    if (textField == self.tfCity) {
        return [self.addresses getCities];
    }
    else if (textField == self.tfState) {
        return [self.addresses getStates];
    }
    return nil;
}

#pragma mark - AppManagerProtocol
- (void)didFinishDownloadingTags:(NSDictionary *)tags {
    if (self.isService == NO) {
        [self.selectionView setAllTags:tags];
        [self.selectionView reloadData];
    }
}

- (void)didFinishDownloadingServiceTags:(NSDictionary *)tags {
    if (self.isService) {
        [self.selectionView setAllTags:tags];
        [self.selectionView reloadData];
    }
}

#pragma mark - SelectionsViewDelegate
- (void)didChangeItemType:(BOOL)isService {
    self.isService = isService;
    NSDictionary *allTags = [[AppManager sharedInstance] getTags:self.isService];
    [self.selectionView setAllTags:allTags];
    [self.selectionView reloadData];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}
@end
