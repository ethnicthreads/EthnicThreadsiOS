//
//  HowItWorksViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "HowItWorksViewController.h"
#import "SignupViewController.h"
#import "HowItWorkView.h"
#import "MenuViewController.h"
#import "UIImageView+Custom.h"
#import "SlideShowModel.h"
#import "CustomImageView.h"
#import "LocationManager.h"
#import "PermissionRequestViewController.h"

#define SLIDE_SHOWS_KEY          @"slide_shows"

@interface HowItWorksViewController () <UIScrollViewDelegate, SlideNavigationControllerDelegate, CBImageViewProtocol, UIAlertViewDelegate, PermissionReuquestDelegate>

@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcEqualWidthLoginExploreButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHorizontalLoginExploreButton;
@property (nonatomic, strong) NSLayoutConstraint            *lcLeadingExploreButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomScrollControl;
@property (nonatomic, strong) NSLayoutConstraint            *lcHeightContentView;

@property (nonatomic, assign) IBOutlet UIView           *vSlideContainer;
@property (nonatomic, assign) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, strong) UIView                    *contentView;
@property (nonatomic, assign) IBOutlet UIPageControl    *pageControl;
@property (nonatomic, assign) IBOutlet UIButton         *menuButton;
@property (nonatomic, assign) IBOutlet UIButton         *exploreButton;
@property (nonatomic, assign) IBOutlet UIView           *accountView;
@property (nonatomic, assign) IBOutlet UIButton         *logInButton;

@property (nonatomic, strong) NSMutableArray            *slideShows;

- (IBAction)handleMenuButton:(id)sender;
- (IBAction)handleExploreButton:(id)sender;
- (IBAction)handleSignUpButton:(id)sender;
@end

@implementation HowItWorksViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SlideNavigationController sharedInstance] prepareMenuForReveal:MenuLeft];
}

- (void)initVariables {
    [super initVariables];
    self.slideShows = [[NSMutableArray alloc] init];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:SLIDE_SHOWS_KEY];
    for (NSDictionary *dict in array) {
        SlideShowModel *slide = [[SlideShowModel alloc] initWithDictionary:dict];
        if (slide) {
            [self.slideShows addObject:slide];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogInNotification:) name:DID_LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOutNotification:) name:DID_LOGOUT_NOTIFICATION object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self initSlideImageViews];
    [self initSubviewsOfSlideScrollView];
    [self.pageControl setNumberOfPages:self.slideShows.count];
    [self.pageControl setCurrentPage:0];
    
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetSlideShow:threadObj:) argument:@""];
}

- (void)updateViewConstraints {
    if ([[UserManager sharedInstance] isLogin]) {
        if ([self.accountView.constraints containsObject:self.lcEqualWidthLoginExploreButton]) {
            [self.accountView removeConstraint:self.lcEqualWidthLoginExploreButton];
            [self.accountView removeConstraint:self.lcHorizontalLoginExploreButton];
            self.lcLeadingExploreButton = [NSLayoutConstraint constraintWithItem:self.exploreButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.accountView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.accountView addConstraint:self.lcLeadingExploreButton];
        }
    }
    else {
        if ([self.accountView.constraints containsObject:self.lcLeadingExploreButton]) {
            [self.accountView removeConstraint:self.lcLeadingExploreButton];
            [self.accountView addConstraint:self.lcEqualWidthLoginExploreButton];
            [self.accountView addConstraint:self.lcHorizontalLoginExploreButton];
        }
    }
    
    [self.logInButton setHidden:[[UserManager sharedInstance] isLogin]];
    self.lcHeightContentView.constant = [UIScreen mainScreen].bounds.size.height - self.lcBottomScrollControl.constant;
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)stopAllThreadsBeforeQuit {
    [super stopAllThreadsBeforeQuit];
}

- (void)updateCurrentLocation:(NSNotification *)noti {
    [self stopSpinner];
    if ([[LocationManager sharedInstance] getCurrentCountry].length > 0) {
        [self handleExploreButton:self.exploreButton];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_CURRENT_LOCATION object:nil];
}

#pragma mark - Notification Center
- (void)didLogInNotification:(NSNotification *)noti {
    [self updateContraintAndRenderScreenIfNeeded];
}

- (void)didLogOutNotification:(NSNotification *)noti {
    [self updateContraintAndRenderScreenIfNeeded];
}

#pragma mark - Private Methods
- (void)initSlideImageViews {
    for (UIView *view in self.vSlideContainer.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < self.slideShows.count; i++) {
        CustomImageView *imageView = [[CustomImageView alloc] init];
        [imageView setAlpha:0.0];
        [imageView setHidden:YES];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.vSlideContainer addSubview:imageView];
        
        NSLayoutConstraint *lc;
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vSlideContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        [self.vSlideContainer addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vSlideContainer attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
        [self.vSlideContainer addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vSlideContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.vSlideContainer addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vSlideContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        [self.vSlideContainer addConstraint:lc];
        
        if (i < 2 && imageView.image == nil) {
            SlideShowModel *slide = [self.slideShows objectAtIndex:i];
            [imageView loadImageForUrl:slide.image type:IMAGE_DONOTHING];
        }
        if (i == self.pageControl.currentPage) {
            [imageView setAlpha:1.0];
            [imageView setHidden:NO];
        }
    }
}

- (void)initSubviewsOfSlideScrollView {
    if (self.contentView) {
        [self.scrollView removeConstraints:self.scrollView.constraints];
        [self.contentView removeFromSuperview];
    }
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height - self.lcBottomScrollControl.constant;
    self.contentView = [[UIView alloc] init];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView addSubview:self.contentView];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.scrollView addConstraint:lc];
    self.lcHeightContentView = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    [self.contentView addConstraint:self.lcHeightContentView];
    
    UIView *beforeView = self.contentView;
    for (int i = 0; i < self.slideShows.count; i++) {
        HowItWorkView *view = [[[UINib nibWithNibName:NSStringFromClass([HowItWorkView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [view setSlideShow:[self.slideShows objectAtIndex:i]];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:view];
        
        lc = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.width];
        [view addConstraint:lc];
        if (beforeView == self.contentView) {
            lc = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:beforeView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        }
        else {
            lc = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:beforeView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
        }
        [self.contentView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [self.contentView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.contentView addConstraint:lc];
        if (i == self.slideShows.count - 1) {
            lc = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:lc];
        }
        
        beforeView = view;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)executeGetSlideShow:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    if (self.slideShows.count == 0) {
        [self startSpinnerWithWaitingText];
    }
    Response *response = [CloudManager getSlideShows];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        NSArray *array = response.getJsonObject;
        if ([self checkNew:array]) {
            NSMutableArray *results = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in array) {
                SlideShowModel *slide = [[SlideShowModel alloc] initWithDictionary:dict];
                if (slide) {
                    [results addObject:slide];
                }
            }
        
            self.slideShows = [NSMutableArray arrayWithArray:results];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.pageControl setNumberOfPages:results.count];
                [self.pageControl setCurrentPage:0];
                [self initSlideImageViews];
                [self initSubviewsOfSlideScrollView];
                [self updateContraintAndRenderScreenIfNeeded];
            });
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:array forKey:SLIDE_SHOWS_KEY];
            [userDefaults synchronize];
        }
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (BOOL)checkNew:(NSArray *)slideShows {
    if (self.slideShows.count != slideShows.count)
        return YES;
    for (int i = 0; i < self.slideShows.count; i++) {
        SlideShowModel *slide = [self.slideShows objectAtIndex:i];
        NSDictionary *dict = [slideShows objectAtIndex:i];
        NSString *slideId = [[dict objectForKey:@"id"] description];
        if (![[slide getIdString] isEqualToString:slideId]) {
            return YES;
        }
    }
    return NO;
}

- (void)detectedCurrentLocationTimeOut {
    [self stopSpinner];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                                    message:NSLocalizedString(@"alert_detect_location_time_out", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_button_ok", @"")
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Button Handle
- (IBAction)handleMenuButton:(id)sender {
    [self handleTouchToMainMenuButton];
}

- (IBAction)handleExploreButton:(id)sender {
    PermissionRequestViewController *vc = [[PermissionRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)didDismissRequestView {
    if ([[LocationManager sharedInstance] getCurrentCountry].length > 0 || ![[LocationManager sharedInstance] authorizationStatusEnable]) {
        [(MenuViewController *)[self getMenuViewController] openDiscoverPage:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:UPDATE_CURRENT_LOCATION object:nil];
        [self startSpinnerWithText:NSLocalizedString(@"spinner_text_wait_country_detecting", @"")];
        [self performSelector:@selector(detectedCurrentLocationTimeOut) withObject:nil afterDelay:30];
    }
}

- (IBAction)handleSignUpButton:(id)sender {
    MenuViewController *menuVc = (MenuViewController *)[self getMenuViewController];
    menuVc.discoverVC.shouldRefreshItems = ITEMS_UPDATESTATUS;
    [menuVc openLoginPage:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0) {
        CGPoint point = scrollView.contentOffset;
        point.y = 0;
        scrollView.contentOffset = point;
    }

    NSInteger pageWidth = scrollView.frame.size.width;
    CGFloat delta = scrollView.contentOffset.x - self.pageControl.currentPage * pageWidth;
    NSInteger currentPage = self.pageControl.currentPage;
    NSInteger preparePage = currentPage;
    CGFloat alpha;
    if (delta > 0) {
        // scroll to right
        preparePage += 1;
        alpha = delta / pageWidth;
    }
    else {
        // scroll to left
        preparePage -= 1;
        alpha = (-delta) / pageWidth;
    }
    if (preparePage < 0 || preparePage >= self.slideShows.count || self.slideShows.count == 0)
        return;
    
    UIImageView *currentImgView = [self.vSlideContainer.subviews objectAtIndex:currentPage];
    UIImageView *prepareImgView = [self.vSlideContainer.subviews objectAtIndex:preparePage];
    [currentImgView setHidden:NO];
    [prepareImgView setHidden:NO];
    [currentImgView setAlpha:1.0f - alpha];
    [prepareImgView setAlpha:alpha];
    
    if ((int)scrollView.contentOffset.x % pageWidth == 0) {
        NSInteger page = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
        if (page < 0 || page >= self.slideShows.count)
            return;
        self.pageControl.currentPage = page;
        
        NSInteger currentPage = self.pageControl.currentPage;
        for (NSInteger i = 0; i < self.vSlideContainer.subviews.count; i++) {
            if (i != currentPage) {
                UIImageView *imgView = [self.vSlideContainer.subviews objectAtIndex:i];
                [imgView setAlpha:0.0];
                [imgView setHidden:YES];
            }
        }
        
        if (currentPage < self.slideShows.count - 1) {
            SlideShowModel *slide = [self.slideShows objectAtIndex:currentPage + 1];
            UIImageView *imgView = [self.vSlideContainer.subviews objectAtIndex:currentPage + 1];
            if (imgView.image == nil) {
                [imgView loadImageForUrl:slide.image type:IMAGE_DONOTHING];
            }
        }
    }
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [(MenuViewController *)[self getMenuViewController] openDiscoverPage:nil];
}
@end
