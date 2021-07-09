//
//  SearchedUserModel.m
//  EthnicThread
//
//  Created by PhuocDuy on 3/26/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BasicInfoUserModel.h"
#import "AppManager.h"
#import "UserManager.h"

@implementation BasicInfoUserModel

- (id)initAnySelerText {
    self = [super init];
    if (self) {
        self.display_name = NSLocalizedString(@"any_seller", @"");
        self.isAnySeller = YES;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        [self setSpecialValue:dict];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    self.avatar = @"";
    [super updateWithDictionary:dict];
    [self setSpecialValue:dict];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    NSDictionary *fbDict = [dict objectForKey:@"facebook_account"];
    if (fbDict.count > 0) {
        if (self.avatar.length == 0) {
            self.avatar = [fbDict objectForKey:@"picture_url"];
        }
        self.email = [fbDict objectForKey:@"email"];
        self.first_name = [fbDict objectForKey:@"first_name"];
        self.last_name = [fbDict objectForKey:@"last_name"];
    }
    
    if (self.avatar.length > 0 && ![self.avatar hasPrefix:@"http"]) {
        NSString *url = [[AppManager sharedInstance] getCloudHostBaseUrl];
        self.avatar = [url stringByAppendingFormat:@"%@", self.avatar];
    }
}

- (NSString *)getDisplayName {
    return (self.display_name.length > 0) ? self.display_name : [self getFullName];
}

- (NSString *)getFullName {
    return [NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name];
}

- (NSString *)getFullAddress {
    return [Utils generateLocationStringFrom:self.address city:self.city state:self.state country:self.country];
}

- (NSString *)getLocation {
    return [Utils generateLocationStringFrom:nil city:self.city state:self.state country:self.country];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[BasicInfoUserModel class]]) {
        if ([[self getIdString] isEqualToString:[(BasicInfoUserModel *)object getIdString]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isMe {
    if ([[UserManager sharedInstance] isLogin])
        return [self isEqual:[[UserManager sharedInstance] getAccount]];
    return NO;
}

#pragma mark - Override
- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *result = [super toDictionary];
    [result setObject:[Utils checkNil:self.email] forKey:@"email"];
    [result setObject:[Utils checkNil:self.first_name] forKey:@"first_name"];
    [result setObject:[Utils checkNil:self.last_name] forKey:@"last_name"];
    [result setObject:[Utils checkNil:self.display_name] forKey:@"display_name"];
    [result setObject:[Utils checkNil:self.avatar] forKey:@"avatar"];
    [result setObject:[Utils checkNil:self.country] forKey:@"country"];
    [result setObject:[Utils checkNil:self.city] forKey:@"city"];
    [result setObject:[Utils checkNil:self.state] forKey:@"state"];
    [result setObject:[Utils checkNil:self.address] forKey:@"address"];
    return result;
}
@end
