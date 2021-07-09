//
//  CreativeAccountModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/5/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "CreativeAccountModel.h"

@implementation CreativeAccountModel

- (NSDictionary *)makeDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[Utils checkNil:self.avatar] forKey:@"avatar"];
    [dict setObject:[Utils checkNil:self.first_name] forKey:@"firstName"];
    [dict setObject:[Utils checkNil:self.last_name] forKey:@"lastName"];
    [dict setObject:[Utils checkNil:self.display_name] forKey:@"displayName"];
    [dict setObject:[Utils checkNil:self.gender] forKey:@"gender"];
    [dict setObject:[Utils checkNil:self.address] forKey:@"address"];
    [dict setObject:[Utils checkNil:self.city] forKey:@"city"];
    [dict setObject:[Utils checkNil:self.state] forKey:@"state"];
    [dict setObject:[Utils checkNil:self.country] forKey:@"country"];
    [dict setObject:@(self.latitude) forKey:@"latitude"];
    [dict setObject:@(self.longitude) forKey:@"longitude"];
    [dict setObject:[Utils checkNil:self.phone] forKey:@"phone"];
    [dict setObject:[Utils checkNil:self.about_me] forKey:@"aboutMe"];
    NSString *termsOfSales = [Utils checkNil:self.terms];
//    termsOfSales = (termsOfSales.length > 0) ? termsOfSales : NSLocalizedString(@"terms_of_sales_default_text", @"");
    [dict setObject:termsOfSales forKey:@"terms"];
    [dict setObject:[Utils checkNil:self.currency] forKey:@"currency"];
    [dict setObject:@((long long)self.birth_day) forKey:@"birthDay"];
    if (self.aNewPassword.length > 0) {
        [dict setObject:[Utils checkNil:self.password] forKey:@"currentPassword"];
        [dict setObject:[Utils checkNil:self.aNewPassword] forKey:@"password"];
        [dict setObject:[Utils checkNil:self.confirmPassword] forKey:@"passwordConfirmation"];
    }
    return dict;
}
@end
