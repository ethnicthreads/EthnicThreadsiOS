//
//  LoginDelegate.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/14/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol UserAuthortyDelegate <NSObject>
- (void)startSignup:(NSString *)email andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName;
- (void)startLogin:(NSString *)email andPassword:(NSString *)password;
- (void)startResetPassword:(NSString *)email;
@end
