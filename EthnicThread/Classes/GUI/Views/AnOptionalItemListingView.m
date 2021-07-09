//
//  AnOptionalItemListingView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AnOptionalItemListingView.h"
#import "Constants.h"
#import "ETPlaceHolderTextView.h"
#import "AutocompleteTextField.h"
#import "LocationManager.h"
#import "MapLoadingView.h"
#import "UITextField+Custom.h"

@interface AnOptionalItemListingView() <UITextViewDelegate, UITextFieldDelegate, AutocompleteDataSource, MapLoadingViewDelegate, UIActionSheetDelegate>
@property (assign, nonatomic) IBOutlet UIButton             *btnSizeS;
@property (assign, nonatomic) IBOutlet UIButton             *btnSizeM;
@property (assign, nonatomic) IBOutlet UIButton             *btnSizeL;
@property (assign, nonatomic) IBOutlet UIButton             *btnSizeXL;
@property (nonatomic, assign) IBOutlet ETPlaceHolderTextView *tvSizeDescription;
@property (nonatomic, assign) IBOutlet ETPlaceHolderTextView *tvItemDescription;
@property (nonatomic, assign) IBOutlet UITextField          *tfYoutubeLink;
@property (nonatomic, assign) IBOutlet UITextField          *tfPrice;
@property (nonatomic, assign) IBOutlet UITextField          *tfAddress;
@property (nonatomic, assign) IBOutlet AutocompleteTextField          *tfCity;
@property (nonatomic, assign) IBOutlet AutocompleteTextField          *tfState;
@property (nonatomic, assign) IBOutlet UIButton             *btnNew;
@property (nonatomic, assign) IBOutlet UIButton             *btnLikeNew;
@property (nonatomic, assign) IBOutlet MapLoadingView       *mapView;
@property (nonatomic, strong) NSTimer                       *timer;
@property (nonatomic, assign) IBOutlet UIView               *vPriveContainer;
@property (nonatomic, assign) IBOutlet UIView               *vLineYoutobe;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightPriceView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomPriceView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightSizeView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomSizeView;
@property (nonatomic, assign) IBOutlet UIView               *vSizeContainer;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightConditionView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomConditionView;
@property (nonatomic, assign) IBOutlet UIView               *vConditionContainer;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightCommonView;
@end

@implementation AnOptionalItemListingView

- (void)initVariables {
    [super initVariables];
}

- (void)initGUI {
    [super initGUI];
    [self setBackgroundColor:LIGHT_GRAY_COLOR];
    
    self.tvSizeDescription.placeholder = NSLocalizedString(@"size_description", @"");
    self.tvSizeDescription.delegate = self;
    self.tvItemDescription.placeholder = NSLocalizedString(@"item_description", @"");
    self.tvItemDescription.delegate = self;
    self.tfYoutubeLink.delegate = self;
    self.tfPrice.delegate = self;
    self.tfAddress.delegate = self;
    self.tfCity.delegate = self;
    self.tfCity.autocompleteDataSource = self;
    self.tfState.delegate = self;
    self.tfState.autocompleteDataSource = self;
    UIColor *color = [UIColor lightGrayColor];
    [self.btnCountry setTitleColor:color forState:UIControlStateSelected];
    [self.btnCountry setSelected:YES];
    
    [self.btnSizeS setTitle:SIZE_S forState:UIControlStateNormal];
    [self.btnSizeS setTitle:SIZE_S forState:UIControlStateSelected];
    [self.btnSizeM setTitle:SIZE_M forState:UIControlStateNormal];
    [self.btnSizeM setTitle:SIZE_M forState:UIControlStateSelected];
    [self.btnSizeL setTitle:SIZE_L forState:UIControlStateNormal];
    [self.btnSizeL setTitle:SIZE_L forState:UIControlStateSelected];
    [self.btnSizeXL setTitle:SIZE_XL forState:UIControlStateNormal];
    [self.btnSizeXL setTitle:SIZE_XL forState:UIControlStateSelected];
    
    [self.btnNew setTitle:NSLocalizedString(@"text_new", @"") forState:UIControlStateNormal];
    [self.btnLikeNew setTitle:NSLocalizedString(@"text_likenew", @"") forState:UIControlStateNormal];
    
    self.tfYoutubeLink.text = self.createdItem.youtube_link;
    
    self.tfPrice.layer.borderColor = [UIColor redColor].CGColor;
    self.tfCity.layer.borderColor = [UIColor redColor].CGColor;
    self.tfState.layer.borderColor = [UIColor redColor].CGColor;
    self.btnCountry.layer.borderColor = [UIColor redColor].CGColor;
    
    [self.tfPrice addTopRightButtonOfKeyBoard:NSLocalizedString(@"done", @"")
                            textColor:[UIColor darkTextColor]
                               target:self
                               action:@selector(didTapDoneButtonOfPriceTextField:)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.btnSizeS.selected = NO;
    self.btnSizeM.selected = NO;
    self.btnSizeL.selected = NO;
    self.btnSizeXL.selected = NO;
    for (NSString *size in self.createdItem.sizes) {
        if ([self.btnSizeS.titleLabel.text isEqualToString:size]) {
            self.btnSizeS.selected = YES;
        }
        if ([self.btnSizeM.titleLabel.text isEqualToString:size]) {
            self.btnSizeM.selected = YES;
        }
        if ([self.btnSizeL.titleLabel.text isEqualToString:size]) {
            self.btnSizeL.selected = YES;
        }
        if ([self.btnSizeXL.titleLabel.text isEqualToString:size]) {
            self.btnSizeXL.selected = YES;
        }
    }
    self.tvSizeDescription.text = self.createdItem.describe_size;
    self.tvItemDescription.text = self.createdItem.desc;
    self.tfYoutubeLink.text = self.createdItem.youtube_link;
    self.tfPrice.text = [NSString stringWithFormat:@"%0.2f", self.createdItem.price];
    [self.btnCurrency setTitle:self.createdItem.currency forState:UIControlStateNormal];
    [self updateLayoutOfLocation];
    
    self.btnNew.selected = NO;
    self.btnLikeNew.selected = NO;
    if ([self.createdItem.condition isEqualToString:CONDITION_NEW]) {
        self.btnNew.selected = YES;
    }
    else if ([self.createdItem.condition isEqualToString:CONDITION_LIKENEW]) {
        self.btnLikeNew.selected = YES;
    }
    
    [self shouldEnableRequired];
}

- (void)updateConstraints {
    if (self.createdItem.isService) {
        self.lcHeightPriceView.constant = 0;
        self.lcBottomPriceView.constant = 0;
        self.lcHeightSizeView.constant = 0;
        self.lcBottomSizeView.constant = 0;
        self.lcHeightConditionView.constant = 0;
        self.lcBottomConditionView.constant = 0;
        self.lcHeightCommonView.constant = 86;
    }
    [super updateConstraints];
}

- (void)setCreatedItem:(CreativeItemModel *)createdItem {
    _createdItem = createdItem;
    self.tvItemDescription.placeholder = [self.createdItem isService] ? NSLocalizedString(@"service_description", @"") : NSLocalizedString(@"item_description", @"");
    [self startScanningLocation];
    
    if (self.createdItem.isService) {
        [self.vPriveContainer setHidden:YES];
        [self.vSizeContainer setHidden:YES];
        [self.vConditionContainer setHidden:YES];
        [self.vLineYoutobe setHidden:YES];
        [self.tfYoutubeLink setHidden:YES];
    }
}

- (void)hideKeyboard {
    [self.tfYoutubeLink resignFirstResponder];
    [self.tfPrice resignFirstResponder];
    [self.tfAddress resignFirstResponder];
    [self.tfCity resignFirstResponder];
    [self.tfState resignFirstResponder];
    [self.tvSizeDescription resignFirstResponder];
    [self.tvItemDescription resignFirstResponder];
}

- (void)startScanningLocation {
    NSString *locationString = [Utils generateLocationStringFrom:self.tfAddress.text
                                                            city:self.tfCity.text
                                                           state:self.tfState.text
                                                         country:[self.btnCountry titleForState:UIControlStateNormal]];
    
    if (locationString.length > 0) {
        [self.mapView displayLocationWithAddress:locationString];
    }
}

- (void)updateSizes {
    [self.createdItem.sizes removeAllObjects];
    if (self.btnSizeS.selected) {
        [self.createdItem.sizes addObject:self.btnSizeS.titleLabel.text];
    }
    if (self.btnSizeM.selected) {
        [self.createdItem.sizes addObject:self.btnSizeM.titleLabel.text];
    }
    if (self.btnSizeL.selected) {
        [self.createdItem.sizes addObject:self.btnSizeL.titleLabel.text];
    }
    if (self.btnSizeXL.selected) {
        [self.createdItem.sizes addObject:self.btnSizeXL.titleLabel.text];
    }
    [self shouldEnableRequired];
}

- (void)shouldEnableRequired {
    if (self.allowEnableRequired == NO || [self.createdItem isForFun])
        return;
    self.tfPrice.layer.borderWidth = 0;
    self.tfCity.layer.borderWidth = 0;
    self.tfState.layer.borderWidth = 0;
    self.btnCountry.layer.borderWidth = 0;
    
    if (self.createdItem.price == 0) {
        self.tfPrice.layer.borderWidth = 1;
    }
    if (self.createdItem.city.length == 0) {
        self.tfCity.layer.borderWidth = 1;
    }
    if (self.createdItem.state.length == 0) {
        self.tfState.layer.borderWidth = 1;
    }
    if (self.createdItem.country.length == 0) {
        self.btnCountry.layer.borderWidth = 1;
    }
}

- (void)updateLayoutOfLocation {
    self.tfAddress.text = self.createdItem.address;
    self.tfCity.text = self.createdItem.city;
    self.tfState.text = self.createdItem.state;
    [self.btnCountry setTitle:self.createdItem.country forState:UIControlStateNormal];
    [self.btnCountry setSelected:(self.createdItem.country.length == 0)];
    [self startScanningLocation];
}

- (IBAction)handleBtnSizeSButton:(id)sender {
    if ([self.createdItem isForFun] == NO && self.createdItem.sizes.count == 1 && [(UIButton *)sender isSelected])
        return;
    _btnSizeS.selected = !_btnSizeS.selected;
    [self updateSizes];
}

- (IBAction)handleBtnSizeMButton:(id)sender {
    if ([self.createdItem isForFun] == NO && self.createdItem.sizes.count == 1 && [(UIButton *)sender isSelected])
        return;
    _btnSizeM.selected = !_btnSizeM.selected;
    [self updateSizes];
}

- (IBAction)handleBtnSizeLButton:(id)sender {
    if ([self.createdItem isForFun] == NO && self.createdItem.sizes.count == 1 && [(UIButton *)sender isSelected])
        return;
    _btnSizeL.selected = !_btnSizeL.selected;
    [self updateSizes];
}

- (IBAction)handleBtnSizeXLButton:(id)sender {
    if ([self.createdItem isForFun] == NO && self.createdItem.sizes.count == 1 && [(UIButton *)sender isSelected])
        return;
    _btnSizeXL.selected = !_btnSizeXL.selected;
    [self updateSizes];
}

- (IBAction)handleNewButton:(id)sender {
    self.btnNew.selected = !self.btnNew.selected;
    self.btnLikeNew.selected = NO;
    self.createdItem.condition = CONDITION_NEW;
    [self shouldEnableRequired];
}

- (IBAction)handleLikeNewButton:(id)sender {
    self.btnLikeNew.selected = !self.btnLikeNew.selected;
    self.btnNew.selected = NO;
    self.createdItem.condition = CONDITION_LIKENEW;
    [self shouldEnableRequired];
}

- (void)timerTick:(NSTimer *)timer {
    [self startScanningLocation];
}

- (void)didTapDoneButtonOfPriceTextField:(id)sender {
    [self.tfPrice resignFirstResponder];
}

- (void)openAddActionSheet {
    self.didPopupLoctionActionSheet = YES;
    NSString *title = [NSString stringWithFormat:@"It has been using your %@", self.createdItem.isDefaultAddress ? [NSLocalizedString(@"default_address", @"") lowercaseString] : [NSLocalizedString(@"current_location", @"") lowercaseString]];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"default_address", @""), NSLocalizedString(@"current_location", @""), nil];
    [sheet showInView:self];
}

#pragma mark - MapLoadingViewDelegate
- (void)didScanLocation:(CLLocationCoordinate2D)coordinate {
    self.createdItem.latitude = coordinate.latitude;
    self.createdItem.longitude = coordinate.longitude;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.tvSizeDescription) {
        self.createdItem.describe_size = self.tvSizeDescription.text;
    }
    else if (textView == self.tvItemDescription) {
        self.createdItem.desc = self.tvItemDescription.text;
    }
    [self shouldEnableRequired];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return (![Utils checkEmojiLanguage:[[textView textInputMode] primaryLanguage]]);
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.tfPrice) {
        if (self.createdItem.price == 0) {
            self.tfPrice.text = [NSString stringWithFormat:@"%0.2f", self.createdItem.price];
        }
    }
    
    // set if filling by autocomplete
    if (textField == self.tfCity) {
        self.createdItem.city = textField.text;
    }
    else if (textField == self.tfState) {
        self.createdItem.state = textField.text;
    }
    if (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState) {
        [self startScanningLocation];
    }
    [self shouldEnableRequired];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.tfPrice) {
        if ([self.tfPrice.text doubleValue] == 0) {
            self.tfPrice.text = @"";
        }
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
    
    NSMutableString *text = [NSMutableString stringWithString:textField.text];
    [text replaceCharactersInRange:range withString:string];
    
    if (textField == self.tfYoutubeLink) {
        self.createdItem.youtube_link = text;
    }
    else if (textField == self.tfPrice) {
        self.createdItem.price = [text doubleValue];
    }
    else if (textField == self.tfAddress) {
        self.createdItem.address = text;
    }
    else if (textField == self.tfCity) {
        self.createdItem.city = text;
    }
    else if (textField == self.tfState) {
        self.createdItem.state = text;
    }
    if (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerTick:) userInfo:nil repeats:NO];
    }
    [self shouldEnableRequired];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.didPopupLoctionActionSheet == NO && (textField == self.tfAddress || textField == self.tfCity || textField == self.tfState)) {
        [self openAddActionSheet];
        return NO;
    }
    return YES;
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 || buttonIndex == 1) {
        if (buttonIndex == 0) {
            [self.createdItem useDefaultAddress];
        } else if (buttonIndex == 1) {
            [self.createdItem useCurrentLocation];
        }
        [self updateLayoutOfLocation];
    }
}
@end
