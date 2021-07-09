//
//  AppDelegate.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "AppManager.h"
#import "SlideNavigationController.h"
#import "HowItWorksViewController.h"
#import "UserManager.h"
#import "LocationManager.h"
#import "UIAlertView+Custom.h"
#import "InboxViewController.h"
#import "ContactSellerViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "PermissionRequestViewController.h"
#import "Notification.h"
#import <Firebase.h>
#import <FBSDKCoreKit.h>
#import <UserNotifications/UserNotifications.h>


#define PERMISSION_ALERT @"PERMISSION_ALERT"

@interface AppDelegate () <UIAlertViewDelegate, FIRMessagingDelegate, UNUserNotificationCenterDelegate>
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, assign) BOOL subscribedToTopic;
@property (nonatomic, strong) NSDictionary *registrationOptions;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationAfterDownloadCompleted:) name:DOWNLOAD_COMPLETED_NOTIFICATION object:nil];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // Override point for customization after application launch.
    [Fabric with:@[CrashlyticsKit]];
    [AppManager sharedInstance];
    [UserManager sharedInstance];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    UIViewController *vc = nil;
    MenuViewController *menuVC = [[MenuViewController alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        // app already launched
        vc = [[DiscoverViewController alloc] init];
        menuVC.discoverVC = (DiscoverViewController *)vc;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        vc = [[HowItWorksViewController alloc] init];
    }
    [FIRApp configure];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    SlideNavigationController *nav = [[SlideNavigationController alloc] initWithRootViewController:vc];
    nav.leftMenu = menuVC;

    [self.window setRootViewController:nav];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
}

- (void)onTokenRefresh {
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSString *token = [[FIRInstanceID instanceID] token];
    DLog(@"The GCM registration token needs to be changed.:%@", token);
    if (token.length != 0) {
        [[AppManager sharedInstance] updateDeviceToken:token];
    }
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message
    NSLog(@"%@", [remoteMessage appData]);
}
#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL fb = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                          annotation:annotation];

    BOOL et = [self handleOpenURL:url];
    return fb | et;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL fb = [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url options:options];
    BOOL et = [self handleOpenURL:url];
    return fb | et;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *target = [notification userInfo];
    if (target) {
        [self openPageFromRemoteNotification:target];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *target = response.notification.request.content.userInfo;
    if (target) {
        [self openPageFromRemoteNotification:target];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self registerForPushNotifications];
    LocationManager *locationManager = [LocationManager sharedInstance];
    if (![locationManager isReadyCurrentLocation] && [locationManager authorizationStatusEnable]) {
        [[LocationManager sharedInstance] updateLocation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [FBAppCall handleDidBecomeActive];
    [self connectToFcm];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PERMISSION_ALERT]) {
        if ([[LocationManager sharedInstance] authorizationStatusEnable]) {
            [[LocationManager sharedInstance] updateLocation];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)handleNotificationAfterDownloadCompleted:(NSNotification*)notification{
    if (_isReceivedNotification) {
        [self openPageFromRemoteNotification:_dictionary];
        _isReceivedNotification=NO;
    }
}

#pragma mark - RemoteNotificationsWithDeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    [[EventManager shareInstance] fireEventWithType:ET_DID_TURN_ON_NOTIFICATION result:nil channel:CHANNEL_UI];
    NSString *deviceToken = [[[[token description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    DLog(@"deviceToken: %@", deviceToken);
    NSString *aToken = [[FIRInstanceID instanceID] token];
    DLog(@"Registration Token: %@", aToken);
    if (aToken.length != 0) {
        [[AppManager sharedInstance] updateDeviceToken:aToken];
    }
}

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"Failed to register with error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DLog(@"userInfo: %@", userInfo);
    Notification *notification = [[Notification alloc] initWithDictionary:userInfo];
    if (userInfo) {
        AccountModel *account = [[UserManager sharedInstance] getAccount];
        [account setUnread_notifications:[[userInfo objectForKey:@"badge"] integerValue]];
        if (application.applicationState == UIApplicationStateActive) {
            UIViewController *topVc = [SlideNavigationController sharedInstance].topViewController;
            if ([topVc isKindOfClass:[ContactSellerViewController class]]) {
                NSDictionary *dict = [userInfo objectForKey:@"target"];
                NSNumber *userId = [dict objectForKey:@"user_id"];
                NSNumber *alertId = [dict objectForKey:@"alert_id"];
                ContactSellerViewController *ctVc = (ContactSellerViewController *)topVc;
                if ([userId isEqual:[NSNumber numberWithInteger:[ctVc.userId integerValue]]]) {
                    NSNumber *messId = [dict objectForKey:@"id"];
                    [ctVc didReceiveDerectMessage:messId notifId:alertId userId:userId];
                    return;
                }
            }
        }
        else if (application.applicationState == UIApplicationStateBackground)
        {
            Notification *notif = [[Notification alloc] initWithDictionary:userInfo];
            if (notif.contextDevice.length != 0) {// Handle admin push
                if (notif.shouldHanldeThisNotification && notif.isLocationMatched) {
                    [self sendLocalNotificationWith:notif.getMessage userInfo:notif.userInfo];
                }
            } else { //handle other push
                [self sendLocalNotificationWith:notif.body userInfo:notif.userInfo];
            }
        } else {
            _isReceivedNotification=YES;
            _dictionary=userInfo;
        }
    }
}

- (BOOL)isOldNotificationFormat:(NSDictionary *)dict {
    NSDictionary *aps = [dict objectForKey:@"aps"];
    if (![Utils isNilOrNull:aps] && [aps isKindOfClass:[NSDictionary class]]) {
        if (aps.allKeys.count > 1) {
            return YES;
        }
    }
    return NO;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    DLog(@"userInfo: %@", userInfo);
    if ([self isOldNotificationFormat:userInfo]) {
        return;
    }
    Notification *notification = [[Notification alloc] initWithDictionary:userInfo];
    if (userInfo) {
        AccountModel *account = [[UserManager sharedInstance] getAccount];
        [account setUnread_notifications:[[userInfo objectForKey:@"badge"] integerValue]];
        if (application.applicationState == UIApplicationStateActive) {
            UIViewController *topVc = [SlideNavigationController sharedInstance].topViewController;
            if ([topVc isKindOfClass:[ContactSellerViewController class]]) {
                NSNumber *userId = notification.user_id;
                NSNumber *alertId = notification.alert_id;
                ContactSellerViewController *ctVc = (ContactSellerViewController *)topVc;
                if ([userId isEqual:[NSNumber numberWithInteger:[ctVc.userId integerValue]]]) {
                    NSNumber *messId = notification.id;
                    [ctVc didReceiveDerectMessage:messId notifId:alertId userId:userId];
                    return;
                }
            }
        }
        else if (application.applicationState == UIApplicationStateInactive) {
            [self openPageFromRemoteNotification:userInfo];
        } else if (application.applicationState == UIApplicationStateBackground) {
            Notification *notif = [[Notification alloc] initWithDictionary:userInfo];
            if (notif.contextDevice.length != 0) {// Handle admin push
                if (notif.shouldHanldeThisNotification && notif.isLocationMatched) {
                    [self sendLocalNotificationWith:notif.body userInfo:notif.userInfo];
                }
            } else { //handle other push
                [self sendLocalNotificationWith:notif.getMessage userInfo:notif.userInfo];
            }
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)sendLocalNotificationWith:(NSString *)body userInfo:(NSDictionary *)userInfo {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    body = [Utils convertUnicodeToEmoji:body];
    DLog(@"Body Converted:%@", body);
    [localNotif setAlertBody:body];
    [localNotif setUserInfo:userInfo];
    [localNotif setSoundName:UILocalNotificationDefaultSoundName];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

#pragma mark - Private Method
- (void)registerForPushNotifications {
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
             }
             ];
            
            // For iOS 10 display notification (sent via APNS)
            [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
            // For iOS 10 data message (sent via FCM)
            
            
            [FIRMessaging messaging].delegate = self;
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }
    
    // [START configure_firebase]
    if ([FIRApp defaultApp] == nil) {
        [FIRApp configure];
    }
    [self connectToFcm];
    // [END configure_firebase]
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTokenRefresh)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    NSString *token = [[FIRInstanceID instanceID] token];
    DLog(@"Registration Token: %@", token);
}

- (void)setupGCM {
    __weak typeof(self) weakSelf = self;
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            DLog(@"Registration Token: %@", registrationToken);
            [[AppManager sharedInstance] updateDeviceToken:registrationToken];
        } else {
            DLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
        }
    };
}

- (void)openPageFromRemoteNotification:(NSDictionary *)userInfo {
    MenuViewController *menuVc = (MenuViewController *)[SlideNavigationController sharedInstance].leftMenu;
    Notification *notification = [[Notification alloc] initWithDictionary:userInfo];
    if (notification.contextDevice.length != 0) { //Handle admin push
        DLog(@"Handle ADmin Push");
        if ([notification.mentioned_user_id description].length > 0) {
            [menuVc openDiscoverPage:(^(void) {
                NSNumber *userId = [NSNumber numberWithInteger:[notification.mentioned_user_id integerValue]];
                [menuVc.discoverVC openMyProfilePage:userId];
            })];
        } else if ([notification.mentioned_item_id description].length > 0) {
            [menuVc openDiscoverPage:(^(void) {
                NSNumber *itemId = @([notification.mentioned_item_id integerValue]);// id of item in tell follower push
                [menuVc.discoverVC openMoreInfoByItemId:itemId shouldOpenComments:NO];
            })];
        } else if ([notification.advertising_url description].length > 0) {
            [menuVc openDiscoverPage:(^(void) {
                [menuVc.discoverVC openAdvertisingUrl:notification.advertising_url];
            })];
        }
        return;
    }
    NSDictionary *dict = [Utils getDictionaryFromObject:[userInfo objectForKey:@"target"]];
    if ([@"Message" isEqualToString:notification.type]) {
        UIViewController *topVc = [SlideNavigationController sharedInstance].topViewController;
        if (topVc == nil)
            return;
        
        NSNumber *userId = notification.user_id;
        NSDictionary *userDict = [dict objectForKey:@"user"];
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", [userDict objectForKey:@"first_name"], [userDict objectForKey:@"last_name"]];
        if ([topVc isKindOfClass:[InboxViewController class]]) {
            [(InboxViewController *)topVc openContactPageWithUser:userId andFulName:fullName];
        }
        else {
            InboxViewController *vc = [[InboxViewController alloc] init];
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                                  withSlideOutAnimation:YES
                                                                          andCompletion:^(void) {
                                                                              [vc openContactPageWithUser:userId andFulName:fullName];
                                                                          }];
        }
        [menuVc updateMenuStatus:INBOX];
    }
    else if ([@"Comment" isEqualToString:notification.type] ||
             [@"Like" isEqualToString:notification.type] ||
             [@"Item" isEqualToString:notification.type]) {
        [menuVc openDiscoverPage:(^(void) {
            NSNumber *itemId = notification.id;// id of item in tell follower push
            if (notification.item_id) {
                itemId = notification.item_id;// id of item in comment push
            }
            [menuVc.discoverVC openMoreInfoByItemId:itemId shouldOpenComments:[@"Comment" isEqualToString:notification.type]];
        })];
    }
    else if ([@"Review" isEqualToString:notification.type] ||
             [@"Follow" isEqualToString:notification.type]) {
        [menuVc openDiscoverPage:(^(void) {
            NSNumber *userId = notification.user_id;
            [menuVc.discoverVC openMyProfilePage:userId];
        })];
    } else {
        DLog(@"Admin Push");
    }
}

- (BOOL)handleOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"ethnicthread"]) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        }
        MenuViewController *menuVc = (MenuViewController *)[SlideNavigationController sharedInstance].leftMenu;
        if ([params objectForKey:@"user_id"]) {
            [menuVc openDiscoverPage:(^(void) {
                NSNumber *userId = [NSNumber numberWithInt:[[params objectForKey:@"user_id"] intValue]];
                [menuVc.discoverVC openMyProfilePage:userId];
            })];
            return YES;
        } else if ([params objectForKey:@"talent"]) {
            [menuVc openDiscoverPage:^{
                NSNumber *itemID = [NSNumber numberWithInt:[[params objectForKey:@"talent"] intValue]];
                [menuVc.discoverVC openMoreInfoByItemId:itemID shouldOpenComments:NO];
            }];
            return YES;
        } else if ([params objectForKey:@"style"]) {
            [menuVc openDiscoverPage:^{
                NSNumber *itemID = [NSNumber numberWithInt:[[params objectForKey:@"style"] intValue]];
                [menuVc.discoverVC openMoreInfoByItemId:itemID shouldOpenComments:NO];
            }];
            return YES;
        } else if ([params objectForKey:@"invite_friend"]) {
            //ethnicthread://?invite_friend=9f7ead91g
//            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeAcceptFriendInvitation:threadObj:) argument:[params objectForKey:@"invite_friend"]];
            if ([[UserManager sharedInstance] isLogin]) {
                [[AppManager sharedInstance] acceptFriendInvitationWithCode:[params objectForKey:@"invite_friend"]];
            } else {
                [[AppManager sharedInstance] saveInvitationCode:[params objectForKey:@"invite_friend"]];
            }
        }
    }
    return NO;
}

#pragma mark - Public method implementation
- (void)logOut {
    [[[UserManager sharedInstance] getAccount] setUnread_notifications:0];
    [[UserManager sharedInstance] logOut];
//    [[FIRApp defaultApp] deleteApp:^(BOOL success) {
//        
//    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_LOGOUT_NOTIFICATION object:nil userInfo:nil];
//    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)showAlertToRequireLogin:(NSDictionary *)userInfo {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_info", @"")
                                                    message:NSLocalizedString(@"alert_please_logedin", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                          otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alert.context = userInfo;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSDictionary *userInfo = (NSDictionary *)alertView.context;
        [[NSNotificationCenter defaultCenter] postNotificationName:WILL_LOGIN_NOTIFICATION object:nil userInfo:userInfo];
        MenuViewController *menuVc = (MenuViewController *)[SlideNavigationController sharedInstance].leftMenu;
        [menuVc openLoginPage:userInfo];
    }
}
@end
