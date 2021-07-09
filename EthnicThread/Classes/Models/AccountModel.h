//
//  AccountModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SellerModel.h"

@interface AccountModel : SellerModel
@property (nonatomic, retain) NSString * password;
@property (nonatomic, strong) NSString * facebook_id;
@property (nonatomic, assign) NSInteger  sign_in_count;
@property (nonatomic, assign) NSInteger  unread_notifications;

- (BOOL)isLoginViaFacebook;
- (BOOL)checkRequiredFields;
- (SellerModel *)makeSeller;
@end
