//
//  Request.m
//  REP
//
//  Created by Phan Nam on 8/5/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "Request.h"
#import "Utils.h"
#import "Constants.h"
#import "Categories.h"
#import "AppManager.h"

@interface Request()
@property (nonatomic, retain) NSMutableDictionary       *additionalHeaders;
@property (nonatomic, strong) NSString                  *externalUrl;
@end

@implementation Request

- (id)init {
    if (self = [super init]) {
        _paramDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.additionalHeaders = [NSMutableDictionary dictionary];
        self.method = @"POST";
        _shouldFollowRedirect = YES;
        _rqType = RQ_NOCACHE;
        _cacheType = CT_RESPONSE;
        _shouldSilentLogin = YES;
        _shouldAddAccesToken = YES;
        _shouldPrintLog = YES;
    }
    return self;
}

- (BOOL)hasBody {
    if ([_method caseInsensitiveCompare:@"post"] == NSOrderedSame ||
        [_method caseInsensitiveCompare:@"put"] == NSOrderedSame ||
        [_method caseInsensitiveCompare:@"delete"] == NSOrderedSame) {
        return TRUE;
    }
    return FALSE;
}

- (void)addParameter:(NSString *)name value:(id)val {
    if (!name || !val) {
        return;
    }
    if ([val isKindOfClass:[NSString class]]) {
        //val = [Utils makeJsonEscapeCharacter:val];
    }
    [self.paramDict setValue:val forKey:name];
}

- (NSData *)getBodyOfRequestInJson {
    if (self.customBody != nil) return self.customBody;
	if ([self.paramDict count] == 0) return nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.paramDict options:kNilOptions error:&error];
    if (error) {
        DLog(@"Generate JSON data failed: %@", error);
        return nil;
    }
    return data;
}

- (NSString *)getTargetRequestURL {
    NSString *url = [[[AppManager sharedInstance] getServiceApis] objectForKey:[NSString stringWithFormat:@"cloud.api.url.%@.%@", self.service, self.entry]];
    if (url.length == 0) {
        return _externalUrl;
    }
    if (self.trailingParam.length > 0) {
        url = [url stringByAppendingFormat:@"/%@", self.trailingParam];
    }
    if ([self.method isEqualToString:@"GET"]) {
        NSString *parameterList = [self parameterListForGetMethod];
        if (parameterList.length > 0) {
            url = [NSString stringWithFormat:@"%@?%@", url, [self parameterListForGetMethod]];
        }
    }
    return url;//[url urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (void)setAdditionalHeaderName:(NSString *)name value:(NSString *)val {
    [_additionalHeaders setValue:val forKey:name];
}

- (NSDictionary *)getAdditionalHeaders {
    return _additionalHeaders;
}

#pragma mark - cache methods
- (NSString *)getTargetKeyForRequest {
    //check cached folder
    //Nam: note - shouldn't use NSData to hash.
    NSMutableString *key = [NSMutableString string];
    [key appendString:[self getTargetRequestURL]];
    if ([self hasBody]) {
        NSString *body = [[NSString alloc] initWithData:[self getBodyOfRequestInJson] encoding:NSUTF8StringEncoding];
        [key appendString:body];
    }
    return [NSString stringWithFormat:@"%@", [key md5]];
}

- (void)setCustomUrl:(NSString *)customUrl {
    self.externalUrl = customUrl;
}
#pragma mark - Private methods
- (NSString *)parameterListForGetMethod {
    NSMutableString *strParams = [[NSMutableString alloc] init];
    NSArray *allkeys = [self.paramDict allKeys];
    for (NSInteger index = 0; index < allkeys.count; index ++) {
        NSString *key = [allkeys objectAtIndex:index];
        NSString *value = [[self.paramDict objectForKey:key] urlEncodeUsingEncoding:NSUTF8StringEncoding];
        if (index == 0) {
            [strParams appendFormat:@"%@=%@", key, value];
        }
        else {
            [strParams appendFormat:@"&%@=%@", key, value];
        }
	}
    return [NSString stringWithString:strParams];
}
@end
