//
//  BaseViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.

#import <UIKit/UIKit.h>
#import "OperationManager.h"
#import "MBProgressHUD.h"
#import "Response.h"
#import "Utils.h"
#import "Constants.h"
#import "CloudManager.h"
#import "AppManager.h"
#import "UserManager.h"
#import "ImageBgView.h"
#import "CachedManager.h"
#import "DownloadManager.h"
#import "Categories.h"
#import "SlideNavigationController.h"
#import "BaseView.h"

@interface BaseViewController : UIViewController {
    CGSize kbSize;
}

@property (strong, nonatomic) id<OperationProtocol>     workingThread;
//constraints
@property (nonatomic, strong) IBOutlet NSLayoutConstraint        *lcTop;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint        *lcBottom;

- (void)initVariables;
- (void)initComponentUI;
- (void)layoutSubviews;
- (void)stopAllThreadsBeforeQuit;
- (BOOL)shouldHideStatusBar;
- (BOOL)shouldHideNavigationBar;
- (void)startSpinnerWithWaitingText;
- (void)startUnTouchableSpinnerWithWaitingText;
- (void)startSpinnerWithText:(NSString *)txt;
- (void)stopSpinner;
- (void)keyboardWasShown:(NSNotification *)noti;
- (void)keyboardWillHide:(NSNotification *)noti;
- (BOOL)isResponseSuccessful:(Response *)response;
- (BOOL)isResponseSuccessful:(Response *)response shouldShowAlert:(BOOL)showed;
- (void)updateContraintAndRenderScreenIfNeeded;
- (void)showAlertToRequireLogin:(NSDictionary *)userInfo;
- (void)willOpenLeftMenu;

- (void)setNavigationBarTitle:(NSString *)title andTextColor:(UIColor*)textColor;
- (void)setLeftNavigationItem:(NSString *)title andTextColor:(UIColor *)textColor andButtonImage:(UIImage *)image andFrame:(CGRect)frame;
- (void)setRightNavigationItem:(NSString *)title andTextColor:(UIColor *)textColor andButtonImage:(UIImage *)image andFrame:(CGRect)frame;
- (void)handlerRightNavigationItem:(id)sender;
- (void)handlerLeftNavigationItem:(id)sender;
- (void)handleTouchToMainMenuButton;
- (UIViewController *)getMenuViewController;
@end
