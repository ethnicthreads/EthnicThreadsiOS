//
//  CreateProfileStep2ViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CreateProfileStep2ViewController.h"
#import "DatePickerViewController.h"
#import "MenuViewController.h"
#import "PickerViewController.h"
#import "ETPlaceHolderTextView.h"
#import "UITextField+Custom.h"

@interface CreateProfileStep2ViewController () <DatePickerViewControllerDelegate, UITextViewDelegate, PickerViewControllerDelegate>
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidth;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightSaveButton;

@property (nonatomic, assign) IBOutlet UIButton             *btnSave;
@property (nonatomic, assign) IBOutlet UIButton             *btnBirthDay;
@property (nonatomic, assign) IBOutlet UITextField          *tfPhone;
@property (nonatomic, assign) IBOutlet ETPlaceHolderTextView *tvAboutMe;
@property (nonatomic, assign) IBOutlet ETPlaceHolderTextView *tvTermsOfSales;
@property (nonatomic, assign) IBOutlet UIButton             *btnCurrency;

@property (nonatomic, assign) NSInteger             currencyIndex;

- (IBAction)handleBirthDayButton:(id)sender;
- (IBAction)handleSaveButton:(id)sender;
@end

@implementation CreateProfileStep2ViewController

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
    self.currencyIndex = DEFAULT_CURENTCY_INDEX;
    NSString *currency = [[UserManager sharedInstance] getAccount].currency;
    if (currency.length > 0) {
        NSInteger index = [CURRENCIES indexOfObject:currency];
        if (index >= 0 && index < CURRENCIES.count) {
            self.currencyIndex = index;
        }
    }
}

- (void)initComponentUI {
    [super initComponentUI];
    CGRect rect = CGRectMake(15, 5, 40, 50);
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_back_button"] andFrame:rect];
    
    self.tfPhone.text = self.creativeAccount.phone;
    if ([self.creativeAccount getBirthDayString].length > 0) {
        [self.btnBirthDay setTitle:[self.creativeAccount getBirthDayString] forState:UIControlStateNormal];
    }
    [self.tfPhone addTopRightButtonOfKeyBoard:NSLocalizedString(@"done", @"")
                            textColor:[UIColor darkTextColor]
                               target:self
                               action:@selector(didTapDoneButton:)];
    
    self.tvAboutMe.placeholder = NSLocalizedString(@"about_me", @"");
    self.tvAboutMe.placeholderColor = [UIColor lightGrayColor];
    self.tvAboutMe.text = self.creativeAccount.about_me;
    if ([Utils checkNil:self.creativeAccount.terms]) {
        self.creativeAccount.terms = NSLocalizedString(@"terms_of_sales_default_text", @"");
    }
    self.tvTermsOfSales.text = self.creativeAccount.terms;
    self.tvTermsOfSales.placeholder = NSLocalizedString(@"terms_of_sales", @"");
    self.tvTermsOfSales.placeholderColor = [UIColor lightGrayColor];
}

- (void)updateViewConstraints {
    self.lcWidth.constant = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - (64 + self.lcTopContentView.constant + self.lcHeightContentView.constant + self.lcHeightSaveButton.constant);
    self.lcBottomContentView.constant = (height > 15) ? height : 15;
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tvAboutMe setTextColor:BLACK_COLOR_TEXT];
    self.tvAboutMe.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)executeUpdateUserProfile:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager updateUserProfile:[[[UserManager sharedInstance] getAccount] getIdString]
                                            andFormValue:param];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response.getJsonObject];
        if ([param objectForKey:@"password"]) {
            [dict setObject:[param objectForKey:@"password"] forKey:@"password"];
        }
        UserManager *userManager = [UserManager sharedInstance];
        [userManager updateValueWithDictionary:dict
                                andLoginStatus:[dict objectForKey:@"facebook_account"] ? FACEBOOK_LOGIN : EMAIL_LOGIN];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.navigationController popViewControllerAnimated:NO];
            MenuViewController *menuVc = (MenuViewController *)[self getMenuViewController];
            [menuVc updateUIUserStatus];
            [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:nil];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)setCurrencyIndex:(NSInteger)currencyIndex {
    _currencyIndex = currencyIndex;
    NSString *currency = [CURRENCIES objectAtIndex:currencyIndex];
    [self.btnCurrency setTitle:currency forState:UIControlStateNormal];
}

- (IBAction)handleSaveButton:(id)sender {
    self.creativeAccount.phone = self.tfPhone.text;
    self.creativeAccount.about_me = self.tvAboutMe.text;
    self.creativeAccount.terms = self.tvTermsOfSales.text;
    self.creativeAccount.currency = [CURRENCIES objectAtIndex:self.currencyIndex];
    [self.tfPhone resignFirstResponder];
    [self.tvAboutMe resignFirstResponder];
    
    NSDictionary *dict = [self.creativeAccount makeDictionary];
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateUserProfile:threadObj:) argument:dict];
}

- (IBAction)handleBirthDayButton:(id)sender {
    DatePickerViewController *vc = [[DatePickerViewController alloc] init];
    vc.delegate = self;
    [vc setUnitText:NSLocalizedString(@"birthday", @"")];
    [vc setDefaultDate:[[[UserManager sharedInstance] getAccount] getBirthDayDate]];
    vc.transitioningDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [vc.view setFrame:self.view.frame];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.tfPhone resignFirstResponder];
    [self.tvAboutMe resignFirstResponder];
}

- (IBAction)handleCurrencyButton:(id)sender {
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

#pragma mark - DatePickerViewControllerDelegate
- (void)saveDatePickerView:(NSDate *)date {
    NSString *dateString = [date convertToStringWithFormat:DATE_FORMAT_STRING];
    [self.btnBirthDay setTitle:dateString forState:UIControlStateNormal];
    self.creativeAccount.birth_day = [date timeIntervalSince1970];
}

#pragma mark - PickerViewControllerDelegate
- (void)selectedPickerAtIndex:(NSInteger)index hasValue:(id)value {
    self.currencyIndex = index;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return (![Utils checkEmojiLanguage:[[textView textInputMode] primaryLanguage]]);
}

- (void)didTapDoneButton:(id)sender {
    [self.tfPhone resignFirstResponder];
}
@end
