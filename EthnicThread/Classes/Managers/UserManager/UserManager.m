//
//  UserManager.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UserManager.h"
#import "CachedManager.h"
#import "CloudManager.h"
#import "Utils.h"
#import <FBSDKAccessToken.h>
#import <FBSDKCoreKit.h>
#import <FBSDKLoginManager.h>

#define USER_INFO_KEY       @"user_info"

@interface UserManager()
@property (nonatomic, retain) AccountModel             *account;
@end

@implementation UserManager

+ (UserManager *)sharedInstance {
    static UserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_KEY];
        if (jsonData.length > 0) {
            NSError *error = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            if (!error && dict.count > 0) {
                self.account = [[AccountModel alloc] initWithDictionary:dict];
            }
        }
    }
    return self;
}

- (void)updateValueWithDictionary:(NSDictionary *)dict andLoginStatus:(USER_STATUS)loginStatus {
    if (dict.count > 0) {
        _account = [[AccountModel alloc] initWithDictionary:dict];
        [self saveUserInfo:dict];
    }
}

- (AccountModel *)getAccount {
    return self.account;
}

- (CreativeAccountModel *)getCreativeAccount {
    NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_KEY];
    if (jsonData.length > 0) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (!error && dict.count > 0) {
            return [[CreativeAccountModel alloc] initWithDictionary:dict];
        }
    }
    return [[CreativeAccountModel alloc] initWithDictionary:nil];
}

- (BOOL)silentReLogin {
    if (self.account != nil) {
        if (self.account.facebook_id != nil) {
            NSString *facebookToken = [[FBSDKAccessToken currentAccessToken] tokenString];
            if (facebookToken.length > 0) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:self.account.facebook_id forKey:@"facebookId"];
                [dict setObject:facebookToken forKey:@"facebookToken"];
                [dict setObject:self.account.email forKey:@"email"];
                NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                Response *response = [CloudManager logInViaFacebook:body];
                if ([response isHTTPSuccess]) {
                    [self updateValueWithDictionary:response.getJsonObject andLoginStatus:FACEBOOK_LOGIN];
                    return YES;
                }
            }
        }
        else {
            Response *response = [CloudManager logInViaEmail:self.account.email andPassword:self.account.password];
            if ([response isHTTPSuccess]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response.getJsonObject];
                [dict setObject:self.account.password forKey:@"password"];
                [self updateValueWithDictionary:dict andLoginStatus:EMAIL_LOGIN];
                return YES;
            }
        }
    }
    return NO;
}

- (void)saveUserInfo:(NSDictionary *)dict {
    NSData *data = nil;
    if (dict) {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:USER_INFO_KEY];
    [userDefaults synchronize];
}

- (void)logOut {
    if (self.account.facebook_id != nil) {
//        [[FBSession activeSession] closeAndClearTokenInformation];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
        [[[FBSDKLoginManager alloc] init] logOut];
    }
    self.account = nil;
    [self saveUserInfo:nil];
}

- (BOOL)isLogin {
    return self.account != nil;
}

- (BOOL)isLoginViaFacebook {
    return [self.account isLoginViaFacebook];
}
@end
