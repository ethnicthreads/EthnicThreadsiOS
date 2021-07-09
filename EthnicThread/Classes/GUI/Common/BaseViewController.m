//
//  BaseViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "AnimatedTransitioning.h"
#import "AppDelegate.h"
#import "ListedItemsViewController.h"
#import "MoreInfoViewController.h"

@interface BaseViewController () {
    
}
@property (nonatomic, retain) MBProgressHUD             *mbProgress;
@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerKeyboardNotification];
    [[UIApplication sharedApplication] setStatusBarHidden:[self shouldHideStatusBar]];
    [self.navigationController setNavigationBarHidden:[self shouldHideNavigationBar]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterKeyboardNotification];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:[self shouldHideStatusBar]];
    [self.navigationController setNavigationBarHidden:[self shouldHideNavigationBar]];
    [self setNeedsStatusBarAppearanceUpdate];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initVariables];
    [self initComponentUI];
    [self layoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
}

- (void)initComponentUI {
    
}

- (void)layoutSubviews {
    
}

- (void)stopAllThreadsBeforeQuit {
    //[[EventManager shareInstance] removeListenerInAllChannels:self];
    [self.workingThread cancel];
    self.workingThread = nil;
    [[OperationManager shareInstance] cancelAllThreadsInTarget:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self retrieveAllSubviewsToStop:self.view];
}

- (void)retrieveAllSubviewsToStop:(UIView *)aViewNode {
    if ([aViewNode isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)aViewNode quit];
    }
    else if ([aViewNode isKindOfClass:[UIButton class]]) {
        [(UIButton *)aViewNode quit];
    }
    else if ([aViewNode isKindOfClass:[BaseView class]]) {
        [(BaseView *)aViewNode stopAllThreads];
    }
    NSArray *subviews = [aViewNode subviews];
    for (UIView *view in subviews) {
        [self retrieveAllSubviewsToStop:view];
    }
}

- (void)updateViewConstraints {
    NSLayoutConstraint *constraint;
    NSArray *constraints = [self.view.constraints copy];
    for (constraint in constraints) {
//        if (constraint == self.lcTop) {
//            [self.view removeConstraint:constraint];
//            CGFloat constant = 0;
//            if (![self shouldHideNavigationBar]) {
//                constant = 64;
//            }
//            self.lcTop = [NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constant];
//            [self.view addConstraint:self.lcTop];
//            ;
//        }
        if (constraint == self.lcBottom) {
            [self.view removeConstraint:constraint];
            CGFloat constant = 0;
            self.lcBottom = [NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constant];
            [self.view addConstraint:self.lcBottom];
        }
    }
    [super updateViewConstraints];
}

- (void)updateContraintAndRenderScreenIfNeeded {
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)willOpenLeftMenu {
    
}

#pragma mark - Spinner
- (void)startSpinnerWithWaitingText {
    [self startSpinnerWithText:NSLocalizedString(@"spinner_text_wait", @"")];
}

- (void)startUnTouchableSpinnerWithWaitingText {
    [self startSpinnerWithText:NSLocalizedString(@"spinner_text_wait", @"")];
    [self.mbProgress setUserInteractionEnabled:YES];
}

- (void)startSpinnerWithText:(NSString *)txt {
    if ([NSThread isMainThread]) {
        [self createSpinnerWithText:txt];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self createSpinnerWithText:txt];
    });
}

- (void)stopSpinner {
    if ([NSThread isMainThread]) {
        if (self.mbProgress) {
            self.mbProgress.hudCounter = self.mbProgress.hudCounter - 1;
            if (self.mbProgress.hudCounter <= 0) {
                [self.mbProgress hide:YES];
                self.mbProgress = nil;
            }
        }
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self stopSpinner];
    });
}

- (void)createSpinnerWithText:(NSString *)txt {
    if (self.mbProgress == nil) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        self.mbProgress = hud;
        
        // Set determinate mode
        self.mbProgress.mode = MBProgressHUDModeIndeterminate;
        self.mbProgress.removeFromSuperViewOnHide = YES;
    }
    [self.mbProgress setUserInteractionEnabled:YES];
    self.mbProgress.labelText = txt;
    
    self.mbProgress.hudCounter = self.mbProgress.hudCounter + 1;
    // Add HUD to screen
    [self.mbProgress showInView:self.view animated:YES];
}

- (BOOL)isResponseSuccessful:(Response *)response shouldShowAlert:(BOOL)showed {
    if (showed) {
        return [self isResponseSuccessful:response];
    }
    return [response isHTTPSuccess];
}

- (BOOL)isResponseSuccessful:(Response *)response {
    if (![response isHTTPSuccess]) {
        //offline
        NSString *message = nil;
        if ([response isHTTPClientError]) {
            // Bad request
            NSDictionary *dict = response.getJsonObject;
            message = [dict objectForKey:@"message"];
        } else {
            message = NSLocalizedString(@"alert_server_error_message", @"");
        }
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"") message:message];
        return NO;
    }
    return YES;
}

#pragma mark - Keyboard Notification
- (void)registerKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)noti {
    NSDictionary* info = [noti userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)keyboardWillHide:(NSNotification *)noti {
    kbSize = CGSizeZero;
}

#pragma mark - Navigationbar
- (BOOL)shouldHideNavigationBar {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldHideStatusBar {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return [self shouldHideStatusBar];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self stopAllThreadsBeforeQuit];
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)setNavigationBarTitle:(NSString *)title andTextColor:(UIColor*)textColor {
    UIView *view = [[UIView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 185.0f, 27.0f)];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 185.0f, 25.0f)];
    [titleLbl setFont:[UIFont fontWithName:MAIN_FONT_BOLD size:LARGE_FONT_SIZE]];
    [titleLbl setTextAlignment:NSTextAlignmentCenter];
    [titleLbl setBackgroundColor:[UIColor clearColor]];
    [titleLbl setTextColor:textColor];
    [titleLbl setText:title];
    [view addSubview:titleLbl];
    if ([self isKindOfClass:[MoreInfoViewController class]] || [self isKindOfClass:[ListedItemsViewController class]]) {
        [view setFrame:CGRectMake(0, 0, 244, 27)];
        [titleLbl setFrame:CGRectMake(0, 0, 244, 25)];
    }
    [self.navigationItem setTitleView:view];
}

- (void)setLeftNavigationItem:(NSString *)title andTextColor:(UIColor *)textColor andButtonImage:(UIImage *)image andFrame:(CGRect)frame {
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:frame];
    [btnEdit addTarget:self action:@selector(handlerLeftNavigationItem:) forControlEvents:UIControlEventTouchUpInside];
    [btnEdit setImage:image forState:UIControlStateNormal];
    btnEdit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnEdit setTitle:title forState:UIControlStateNormal];
    [btnEdit.titleLabel setBackgroundColor:[UIColor clearColor]];
    [btnEdit setTitleColor:textColor forState:UIControlStateNormal];
    [btnEdit.titleLabel setFont:[UIFont fontWithName:MAIN_FONT_REGULAR size:LARGE_FONT_SIZE]];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
}

- (void)setRightNavigationItem:(NSString *)title andTextColor:(UIColor *)textColor andButtonImage:(UIImage *)image andFrame:(CGRect)frame {
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:frame];
    [btnEdit addTarget:self action:@selector(handlerRightNavigationItem:) forControlEvents:UIControlEventTouchUpInside];
    [btnEdit setImage:image forState:UIControlStateNormal];
    [btnEdit setTitle:title forState:UIControlStateNormal];
    [btnEdit setTitleColor:textColor forState:UIControlStateNormal];
    [btnEdit.titleLabel setBackgroundColor:[UIColor clearColor]];
    [btnEdit.titleLabel setFont:[UIFont fontWithName:MAIN_FONT_REGULAR size:LARGE_FONT_SIZE]];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}

- (void)handlerRightNavigationItem:(id)sender {
}

- (void)handlerLeftNavigationItem:(id)sender {
}

#pragma mark - Public Method
- (void)handleTouchToMainMenuButton {
    if ([self conformsToProtocol:@protocol(SlideNavigationControllerDelegate)]) {
        if ([SlideNavigationController sharedInstance].isMenuOpen)
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        else
            [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:nil];
    }
}

- (UIViewController *)getMenuViewController {
    return [SlideNavigationController sharedInstance].leftMenu;
}

- (void)showAlertToRequireLogin:(NSDictionary *)userInfo {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showAlertToRequireLogin:userInfo];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = NO;
    return controller;
}
@end
