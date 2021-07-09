//
//  UserManager.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import <UIKit/UIKit.h>
#import "AccountModel.h"
#import "CreativeAccountModel.h"

@interface UserManager : BaseObject

+ (UserManager *)sharedInstance;
- (void)updateValueWithDictionary:(NSDictionary *)dict andLoginStatus:(USER_STATUS)loginStatus;
- (AccountModel *)getAccount;
- (CreativeAccountModel *)getCreativeAccount;
- (BOOL)silentReLogin;
- (void)logOut;
- (BOOL)isLogin;
- (BOOL)isLoginViaFacebook;
@end
