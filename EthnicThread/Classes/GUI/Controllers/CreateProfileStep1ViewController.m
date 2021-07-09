//
//  CreateProfileStep1ViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CreateProfileStep1ViewController.h"
#import "RadioButton.h"
#import "AutocompleteTextField.h"
#import "ChangePasswordViewController.h"
#import "CreateProfileStep2ViewController.h"
#import "LocationManager.h"
#import "CountriesViewController.h"
#import "MapLoadingView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface CreateProfileStep1ViewController () <AutocompleteDataSource, UITextFieldDelegate, ChangePasswordViewDelegate, SlideNavigationControllerDelegate, CountriesViewControllerDelegate, MapLoadingViewDelegate> {
    BOOL shouldReloadLocation;
    BOOL shouldEnableRequired;
}
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollVIew;

@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidth;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightPasswordView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightContinueButton;
@property (nonatomic, assign) IBOutlet UITextField          *tfUsername;
@property (nonatomic, assign) IBOutlet UITextField          *tfFirstName;
@property (nonatomic, assign) IBOutlet UITextField          *tfLastName;
@property (nonatomic, assign) IBOutlet UITextField          *tfDisplayName;
@property (nonatomic, assign) IBOutlet RadioButton          *btnMale;
@property (nonatomic, assign) IBOutlet RadioButton          *btnFemale;
@property (nonatomic, assign) IBOutlet UITextField          *tfAddress;
@property (nonatomic, assign) IBOutlet AutocompleteTextField          *tfCity;
@property (nonatomic, assign) IBOutlet AutocompleteTextField          *tfState;
@property (nonatomic, assign) IBOutlet UIButton             *btnCountry;
@property (nonatomic, assign) IBOutlet UIButton             *btnContinue;
@property (nonatomic, assign) IBOutlet MapLoadingView       *mapView;
@property (nonatomic, assign) IBOutlet UIView               *vPasswordContain;

@property (nonatomic, assign) BOOL                          changePwVcOpened;
@property (nonatomic, strong) Addresses                     *addresses;
@property (nonatomic, strong) NSTimer                       *timer;

- (IBAction)handleMaleButton:(id)sender;
- (IBAction)handleFemaleButton:(id)sender;
- (IBAction)handleContinueButton:(id)sender;
@end

@implementation CreateProfileStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initVariables {
    [super initVariables];
    self.addresses = [[AppManager sharedInstance] getAddresses];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:UPDATE_CURRENT_LOCATION object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    
    CGRect rect = CGRectMake(15, 5, 40, 50);
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:rect];
    
    self.tfFirstName.layer.borderColor = [UIColor redColor].CGColor;
    self.tfLastName.layer.borderColor = [UIColor redColor].CGColor;
    self.tfCity.layer.borderColor = [UIColor redColor].CGColor;
    self.tfState.layer.borderColor = [UIColor redColor].CGColor;
    self.btnCountry.layer.borderColor = [UIColor redColor].CGColor;
    
    self.tfUsername.text = self.creativeAccount.email;
    self.tfFirstName.text = self.creativeAccount.first_name;
    self.tfLastName.text = self.creativeAccount.last_name;
    self.tfDisplayName.text = self.creativeAccount.display_name;
    [self updateControlsByGender:[self.creativeAccount getGender]];
    self.tfUsername.textColor = LIGHT_BLACK_COLOR_TEXT;
    self.tfUsername.enabled = NO;
    UIColor *color = [UIColor lightGrayColor];
    [self.btnCountry setTitleColor:color forState:UIControlStateSelected];
    [self.btnCountry setSelected:YES];
    [self updateCurrentLocation:nil];
    [[LocationManager sharedInstance] updateLocation];
    
    if ([[UserManager sharedInstance] isLoginViaFacebook]) {
        self.tfFirstName.textColor = LIGHT_BLACK_COLOR_TEXT;
        self.tfFirstName.enabled = NO;
        self.tfLastName.textColor = LIGHT_BLACK_COLOR_TEXT;
        self.tfLastName.enabled = NO;
        if (!self.btnMale.selected) {
            self.btnMale.enabled = NO;
            [self.btnMale setTitleColor:LIGHT_BLACK_COLOR_TEXT forState:UIControlStateNormal];
        }
        else {
            self.btnFemale.enabled = NO;
            [self.btnFemale setTitleColor:LIGHT_BLACK_COLOR_TEXT forState:UIControlStateNormal];
        }
        [self.vPasswordContain setHidden:YES];
    }
    [self startSearchLocation];
    [[AppManager sharedInstance] updateAddresses:YES];
}

- (void)updateViewConstraints {
    self.lcWidth.constant = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - (64 + self.lcTopContentView.constant + self.lcHeightContentView.constant + self.lcHeightContinueButton.constant);
    self.lcBottomContentView.constant = (height > 15) ? height : 15;
    if ([self.creativeAccount isLoginViaFacebook]) {
        self.lcHeightPasswordView.constant = 0;
        [self.vPasswordContain setHidden:YES];
    }
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

- (void)shouldEnableRequireFields {
    if (shouldEnableRequired == NO) return;
    [self.btnAvatar boderWidth:3 andColor:[UIColor whiteColor].CGColor];
    [self.btnMale setTitleColor:LIGHT_BLACK_COLOR_TEXT forState:UIControlStateNormal];
    [self.btnFemale setTitleColor:LIGHT_BLACK_COLOR_TEXT forState:UIControlStateNormal];
    self.tfLastName.layer.borderWidth = 0;
    self.tfFirstName.layer.borderWidth = 0;
    self.tfCity.layer.borderWidth = 0;
    self.tfState.layer.borderWidth = 0;
    self.btnCountry.layer.borderWidth = 0;
    
    if (self.creativeAccount.avatar.length == 0) {
        [self.btnAvatar boderWidth:3 andColor:[UIColor redColor].CGColor];
        [self.scrollVIew setContentOffset:CGPointMake(0, 0)];
    }
    if (self.creativeAccount.gender.length == 0) {
        [self.btnMale setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.btnFemale setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    if (self.creativeAccount.last_name.length == 0) {
        self.tfLastName.layer.borderWidth = 1;
    }
    if (self.creativeAccount.first_name.length == 0) {
        self.tfFirstName.layer.borderWidth = 1;
    }
    if (self.creativeAccount.city.length == 0) {
        self.tfCity.layer.borderWidth = 1;
    }
    if (self.creativeAccount.state.length == 0) {
        self.tfState.layer.borderWidth = 1;
    }
    if (self.creativeAccount.country.length == 0) {
        self.btnCountry.layer.borderWidth = 1;
    }
}

- (void)updateCurrentLocation:(NSNotification *)noti {
    if ([self.creativeAccount getFullAddress].length == 0) {
        LocationManager *lm = [LocationManager sharedInstance];
        self.creativeAccount.address = [lm getCurrentAddress];
        self.creativeAccount.city = [lm getCurrentCity];
        self.creativeAccount.state = [lm getCurrentState];
        self.creativeAccount.country = [lm getCurrentCountry];
        self.creativeAccount.latitude = [lm getCurrentLocation].coordinate.latitude;
        self.creativeAccount.longitude = [lm getCurrentLocation].coordinate.longitude;
    }
    self.tfAddress.text = self.creativeAccount.address;
    self.tfCity.text = self.creativeAccount.city;
    self.tfState.text = self.creativeAccount.state;
    [self.btnCountry setTitle:self.creativeAccount.country forState:UIControlStateNormal];
    [self.btnCountry setSelected:(self.creativeAccount.country.length == 0)];
}

- (void)startSearchLocation {
    NSString *locationString = [Utils generateLocationStringFrom:self.tfAddress.text
                                                            city:self.tfCity.text
                                                           state:self.tfState.text
                                                         country:[self.btnCountry titleForState:UIControlStateNormal]];
    if (locationString.length > 0) {
        [self.mapView displayLocationWithAddress:locationString];
    }
}

- (void)willOpenLeftMenu {
    [super willOpenLeftMenu];
    [self.tfUsername resignFirstResponder];
    [self.tfFirstName resignFirstResponder];
    [self.tfLastName resignFirstResponder];
    [self.tfAddress resignFirstResponder];
    [self.tfCity resignFirstResponder];
    [self.tfState resignFirstResponder];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.tfUsername resignFirstResponder];
    [self.tfFirstName resignFirstResponder];
    [self.tfLastName resignFirstResponder];
    [self.tfAddress resignFirstResponder];
    [self.tfCity resignFirstResponder];
    [self.tfState resignFirstResponder];
}

- (void)justChangeAvatar {
    [self shouldEnableRequireFields];
}

- (void)timerTick:(NSTimer *)timer {
    [self startSearchLocation];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState) {
        [self startSearchLocation];
    }
    
    // set if filling by autocomplete
    if (textField == self.tfCity) {
        self.creativeAccount.city = textField.text;
    }
    else if (textField == self.tfState) {
        self.creativeAccount.state = textField.text;
    }
    [self shouldEnableRequireFields];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([Utils checkEmojiLanguage:[[textField textInputMode] primaryLanguage]]) {
        return NO;
    }
    
    NSMutableString *text = [NSMutableString stringWithString:textField.text];
    [text replaceCharactersInRange:range withString:string];
    
    if (textField == self.tfFirstName) {
        self.creativeAccount.first_name = text;
    }
    else if (textField == self.tfLastName) {
        self.creativeAccount.last_name = text;
    }
    else if (textField == self.tfDisplayName) {
        self.creativeAccount.display_name = text;
    }
    else if (textField == self.tfAddress) {
        self.creativeAccount.address = text;
    }
    else if (textField == self.tfCity) {
        self.creativeAccount.city = text;
    }
    else if (textField == self.tfState) {
        self.creativeAccount.state = text;
    }
    
    if (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerTick:) userInfo:nil repeats:NO];
    }
    
    [self shouldEnableRequireFields];
    return YES;
}

- (void)updateControlsByGender:(USER_GENDER)gender {
    self.btnMale.selected = (GENDER_MALE & gender) ? YES : NO;
    self.btnFemale.selected = (GENDER_FEMALE & gender) ? YES : NO;
    if (self.btnMale.selected)
        self.creativeAccount.gender = MALE_TEXT;
    if (self.btnFemale.selected)
        self.creativeAccount.gender = FEMALE_TEXT;
    [self shouldEnableRequireFields];
}

- (IBAction)handleChangePasswordButton:(id)sender {
    self.changePwVcOpened = YES;
    ChangePasswordViewController *vc = [[ChangePasswordViewController alloc] init];
    vc.delegate = self;
    vc.transitioningDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [vc.view setFrame:self.view.frame];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)handleMaleButton:(id)sender {
    [Utils showAlertNoInteractiveWithTitle:nil message:NSLocalizedString(@"disable_male_option", @"")];
//    [self updateControlsByGender:GENDER_MALE];
}

- (IBAction)handleFemaleButton:(id)sender {
    [self updateControlsByGender:GENDER_FEMALE];
}

- (IBAction)handleContinueButton:(id)sender {
    if ([self.creativeAccount checkRequiredFields]) {
        CreateProfileStep2ViewController *vc = [[CreateProfileStep2ViewController alloc] init];
        vc.creativeAccount = self.creativeAccount;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        shouldEnableRequired = YES;
        if (self.creativeAccount.avatar.length == 0) {
            [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_profile_photo", @"")];
        } else {
            [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
        }
        [self shouldEnableRequireFields];
    }
}

- (IBAction)handleCountryButton:(id)sender {
    CountriesViewController *vc = [[CountriesViewController alloc] init];
    vc.countries = [self.addresses getCountries];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - ChangePasswordViewDelegate
- (void)closeChangePasswordView {
    self.changePwVcOpened = NO;
}

- (void)changePasswordSuccess:(NSString *)currentPassword {
    self.changePwVcOpened = NO;
    [[UserManager sharedInstance] getAccount].password = currentPassword;
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}

#pragma mark - MapLoadingViewDelegate
- (void)didScanLocation:(CLLocationCoordinate2D)coordinate {
    self.creativeAccount.latitude = coordinate.latitude;
    self.creativeAccount.longitude = coordinate.longitude;
    [self shouldEnableRequireFields];
}

#pragma mark - CountriesViewControllerDelegate
- (void)searchCountryResult:(NSString *)country {
    [self.btnCountry setTitle:country forState:UIControlStateNormal];
    [self.btnCountry setSelected:(country.length == 0)];
    self.creativeAccount.country = country;
    [self startSearchLocation];
    [self shouldEnableRequireFields];
}
@end
