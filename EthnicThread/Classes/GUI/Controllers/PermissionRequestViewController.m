//
//  PermissionRequestViewController.m
//  EthnicThread
//
//  Created by Nguyen Loc on 11/27/18.
//  Copyright © 2018 CodeBox Solutions Ltd. All rights reserved.
//

#import "PermissionRequestViewController.h"
#import "AppDelegate.h"
#import "DiscoverViewController.h"
#import "SlideNavigationController.h"
#import "HowItWorksViewController.h"
#import "MenuViewController.h"
#import "LocationManager.h"

@interface PermissionRequestViewController () <ChannelProtocol>
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnNotNow;
@end

@implementation PermissionRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PURPLE_COLOR;
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PERMISSION_ALERT"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PERMISSION_ALERT"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self.btnOK setTitle:@"OK" forState:UIControlStateNormal];
    [[EventManager shareInstance] addListener:self channel:CHANNEL_UI];
    
    if (![self isNotificationEnabled]) {
        self.lblMessage.text = NSLocalizedString(@"permission_notification", @"");
    } else {
        self.lblMessage.text = NSLocalizedString(@"permission_location", @"");
    }
    
}

- (void)requestNotificationPermission {
    self.lblMessage.text = NSLocalizedString(@"permission_notification", @"");
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(registerForPushNotifications)]) {
        [delegate registerForPushNotifications];
    }
}

- (void)requestLocationPermission {
    self.lblMessage.text = NSLocalizedString(@"permission_location", @"");
    if ([[LocationManager sharedInstance] authorizationStatusEnable]) {
        
    }
}

- (BOOL)isNotificationEnabled {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (settings) {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications] && [settings types] == UIUserNotificationTypeNone;
    }
    return false;
}

- (IBAction)handleOKButton:(id)sender {
    if ([self.lblMessage.text isEqualToString:NSLocalizedString(@"permission_notification", @"")]) {
        [self requestNotificationPermission];
        [self handleContinueButton:self];
    } else {
        [self requestLocationPermission];
    }
}

- (BOOL)isRequestingNotificationPermission {
    return [self.lblMessage.text isEqualToString:NSLocalizedString(@"permission_notification", @"")];
}

- (IBAction)handleContinueButton:(id)sender {
    if ([self isRequestingNotificationPermission]) {
        [self requestNotificationPermission];
        self.lblMessage.text = NSLocalizedString(@"permission_location", @"");
    } else {
        [self dismissPermissionView];
    }
}

- (void)dismissPermissionView {
    UIViewController *vc = nil;
    if ([self.navigationController isKindOfClass:[SlideNavigationController class]]) {
        SlideNavigationController *nav = (SlideNavigationController *)self.navigationController;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
            // app already launched
            vc = [[DiscoverViewController alloc] init];
            if ([nav.leftMenu isKindOfClass:[MenuViewController class]]) {
                ((MenuViewController *)nav.leftMenu).discoverVC = (DiscoverViewController *)vc;
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([self.delgate respondsToSelector:@selector(didDismissRequestView)]) {
                [self.delgate didDismissRequestView];
            }
//            vc = [[HowItWorksViewController alloc] init];
        }
        [nav setViewControllers:@[vc]];
    }
}

- (void)dispatchChannelEvent:(Event *)aEvent {
    if (aEvent.eventType == ET_DID_TURN_ON_LOCATION) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissPermissionView];
        });
    } else if (aEvent.eventType == ET_DID_TURN_ON_NOTIFICATION && [self isRequestingNotificationPermission]) {
        [self handleOKButton:self];
    }
}
//
//static var isPushNotificationEnabled: Bool {
//    guard let settings = UIApplication.shared.currentUserNotificationSettings
//    else {
//        return false
//    }
//
//    return UIApplication.shared.isRegisteredForRemoteNotifications
//    && !settings.types.isEmpty
//}
@end
