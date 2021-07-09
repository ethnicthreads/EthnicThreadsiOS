//
//  Notification.m
//  EthnicThread
//
//  Created by DuyLoc on 5/21/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "Notification.h"
#import "LocationManager.h"
#import "Constants.h"
#import "Utils.h"
#import "UserManager.h"
#import "AccountModel.h"

@implementation Notification

- (id)initWithDictionary:(NSDictionary *)dict {
    NSDictionary *newDict = [self prepareDictionaryForObject:dict];
    if (self = [super initWithDictionary:newDict]) {
        self.body = [dict objectForKey:@"message"];
        self.userInfo = dict;
        self.contextDevice = [newDict objectForKey:@"context"];
    }
    return self;
}

- (NSDictionary *)prepareDictionaryForObject:(NSDictionary *)dict {
    NSError *error = nil;
    NSString *target = [[dict objectForKey:@"target"] description];
    NSDictionary *jsonTarget = [NSJSONSerialization JSONObjectWithData:[target dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    [newDict addEntriesFromDictionary:jsonTarget];
    return newDict;
}

- (BOOL)shouldHanldeThisNotification {
    BOOL isLoggedIn = [[UserManager sharedInstance] isLogin];
    return [self.contextDevice isEqualToString:CONTEXT_ANY_DEVICE] || (isLoggedIn && [self.contextDevice isEqualToString:CONTEXT_REGISTERED_DEVICE]) || ([self.contextDevice isEqualToString:CONTEXT_UNREGISTERED_DEVICE] && !isLoggedIn);
}

- (NSString *)getMessage {
    return ![Utils isNilOrNull:self.body] ? self.body : self.message;
}

- (BOOL)isLocationMatched {
//    return [self.country isEqualToString:[LocationManager sharedInstance].getCurrentCountry] && [self.city isEqualToString:[LocationManager sharedInstance].getCurrentCity] && [self.state isEqualToString:[LocationManager sharedInstance].getCurrentState];
    DLog(@"Address: %@ - %@ - %@", [[LocationManager sharedInstance] getCurrentCity], [[LocationManager sharedInstance] getCurrentState], [[LocationManager sharedInstance] getCurrentCountry]);
    BOOL countryIsMatched = [self isStringMatched:[[LocationManager sharedInstance] getCurrentCountry] inArrays:[self.country componentsSeparatedByString:@","]];
    BOOL cityIsMatched = [self isStringMatched:[[LocationManager sharedInstance] getCurrentCity] inArrays:[self.city componentsSeparatedByString:@","]];
    BOOL stateIsMatched = [self isStringMatched:[LocationManager sharedInstance].getCurrentState inArrays:[self.state componentsSeparatedByString:@","]];
    return (countryIsMatched && cityIsMatched && stateIsMatched) || [self isProfileLocationMatched];
}

- (BOOL)isProfileLocationMatched {
    AccountModel *user = [[UserManager sharedInstance] getAccount];
    BOOL countryIsMatched = [self isStringMatched:user.country inArrays:[self.country componentsSeparatedByString:@","]];
    BOOL cityIsMatched = [self isStringMatched:user.city inArrays:[self.city componentsSeparatedByString:@","]];
    BOOL stateIsMatched = [self isStringMatched:user.state inArrays:[self.state componentsSeparatedByString:@","]];
    return countryIsMatched && cityIsMatched && stateIsMatched;
}

- (BOOL)isStringMatched:(NSString *)string inArrays:(NSArray *)stringsArray {
    if (stringsArray.count == 0) {
        return YES;
    } else {
        for (NSString *stringInArray in stringsArray) {
            if ([string isEqualToString:stringInArray.trimText] || stringInArray.trimText.length == 0) {
                return YES;
            }
        }
    }
    return NO;
}
@end
