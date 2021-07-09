//
//  AddItemOptionalViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AddItemOptionalViewController.h"
#import "AnOptionalItemListingView.h"
#import "PreviewItemViewController.h"
#import "PickerViewController.h"
#import "CountriesViewController.h"

@interface AddItemOptionalViewController () <UIViewControllerTransitioningDelegate, PickerViewControllerDelegate, CountriesViewControllerDelegate>
@property (nonatomic, assign) IBOutlet UIScrollView             *scvMainScroll;
@property (nonatomic, assign) IBOutlet UIButton                 *btnPreview;
@property (nonatomic, strong) AnOptionalItemListingView         *itemView;
@property (nonatomic, assign) NSInteger             currencyIndex;
@property (nonatomic, assign) BOOL      shouldShowPriceWarning;
@end

@implementation AddItemOptionalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.shouldShowPriceWarning = true;
    self.currencyIndex = DEFAULT_CURENTCY_INDEX;
    NSString *currency = self.createdItem.currency;
    if (currency.length > 0) {
        NSInteger index = [CURRENCIES indexOfObject:currency];
        if (index >= 0 && index < CURRENCIES.count) {
            self.currencyIndex = index;
        }
    }
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:NSLocalizedString(@"post_something", @"") andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    
    self.itemView = [[[UINib nibWithNibName:NSStringFromClass([AnOptionalItemListingView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    if (self.createdItem.isEdit) {
        [self.btnPreview setTitle:[NSLocalizedString(@"done", @"") uppercaseString] forState:UIControlStateNormal];
    }
    self.itemView.addresses = [[AppManager sharedInstance] getAddresses];
    self.itemView.createdItem = self.createdItem;
    [self.itemView.btnCurrency addTarget:self action:@selector(handleCurrencyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.itemView.btnCountry addTarget:self action:@selector(handleCountryButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.itemView.btnCountryArow addTarget:self action:@selector(handleCountryButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.itemView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scvMainScroll addSubview:self.itemView];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.width];
    [self.itemView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    
    [self.itemView.btnCurrency setTitle:self.createdItem.currency forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:UPDATE_CURRENT_LOCATION object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    if ([self.createdItem checkOptionalFields]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
        self.itemView.allowEnableRequired = YES;
        [self.itemView shouldEnableRequired];
    }
}

- (void)updateCurrentLocation:(NSNotification *)noti {
    if (self.createdItem.isDefaultAddress == NO) {
        [self.createdItem useCurrentLocation];
        [self.itemView updateLayoutOfLocation];
    }
}

- (IBAction)handlePreviewButton:(id)sender {
    if (self.shouldShowPriceWarning && [self.createdItem shouldShowSoftWarningForUS]) {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_US_50", @"")];
        self.shouldShowPriceWarning = false;
        return;
    }
    if ([self.createdItem checkOptionalFields]) {
        if (self.createdItem.isEdit) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            PreviewItemViewController *vc = [[PreviewItemViewController alloc] init];
            vc.createdItem = self.createdItem;
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
        }
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
        self.itemView.allowEnableRequired = YES;
        [self.itemView shouldEnableRequired];
    }
}

- (void)handleCurrencyButton:(id)sender {
    [self.itemView hideKeyboard];
    PickerViewController *pickerVC = [[PickerViewController alloc] init];
    [pickerVC setPickerArray:CURRENCIES];
    [pickerVC setUnit:NSLocalizedString(@"currencies", @"")];
    [pickerVC setSelectedIndex:self.currencyIndex];
    [pickerVC setPickerDelegate:self];
    pickerVC.transitioningDelegate = self;
    pickerVC.modalPresentationStyle = UIModalPresentationCustom;
    [pickerVC.view setFrame:self.view.frame];
    [self presentViewController:pickerVC animated:YES completion:nil];
}

- (void)handleCountryButton:(id)sender {
    if (self.itemView.didPopupLoctionActionSheet == NO) {
        [self.itemView openAddActionSheet];
        return;
    }
    CountriesViewController *vc = [[CountriesViewController alloc] init];
    vc.delegate = self;
    vc.countries = [self.itemView.addresses getCountries];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - PickerViewControllerDelegate
- (void)selectedPickerAtIndex:(NSInteger)index hasValue:(id)value {
    self.currencyIndex = index;
    self.createdItem.currency = [CURRENCIES objectAtIndex:self.currencyIndex];
    [self.itemView.btnCurrency setTitle:self.createdItem.currency forState:UIControlStateNormal];
}

#pragma mark - CountriesViewControllerDelegate
- (void)searchCountryResult:(NSString *)country {
    [self.itemView.btnCountry setTitle:country forState:UIControlStateNormal];
    [self.itemView.btnCountry setSelected:(country.length == 0)];
    self.createdItem.country = country;
    [self.itemView startScanningLocation];
}
@end
