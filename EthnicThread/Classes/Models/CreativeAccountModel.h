//
//  CreativeAccountModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/5/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AccountModel.h"

@interface CreativeAccountModel : AccountModel
@property (nonatomic, retain) NSString * aNewPassword;
@property (nonatomic, retain) NSString * confirmPassword;

- (NSDictionary *)makeDictionary;
@end
