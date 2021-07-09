//
//  AppDelegate.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSDictionary *dictionary;
@property (assign, nonatomic) BOOL isReceivedNotification;
 
- (void)logOut;
- (void)showAlertToRequireLogin:(NSDictionary *)userInfo;
- (void)registerForPushNotifications;
- (void)openPageFromRemoteNotification:(NSDictionary *)userInfo;
@end

