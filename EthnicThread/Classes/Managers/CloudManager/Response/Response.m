//
//  Response.m
//  REP
//
//  Created by Phan Nam on 8/5/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "Response.h"
#import "Constants.h"

@interface Response()

@end

@implementation Response

- (id)init {
    self = [super init];
    if (self != nil) {
        _shouldParseResponse = YES;
        _isOnline = YES;
        _isPing = NO;
        _isSucc = YES;
    }
    return self;
}

- (BOOL)shouldOnlyGetResponse {
    return _isPing;
}

- (BOOL)isHTTPSuccess {
    if (!_isOnline) {
        return NO;
    }
//    if (self.connectionError != nil) {
//        if (self.connectionError.code == NSURLErrorTimedOut) {
//            _isOnline = NO;
//            return NO;
//        }
//    }
    return ((_httpCode >= 200 && _httpCode < 300)) ? YES : NO;
}

- (BOOL)isHTTPClientError {
    if (!_isOnline) {
        return NO;
    }
    return ((_httpCode >= 400 && _httpCode < 500)) ? YES : NO;
}

- (BOOL)isHTTPServerError {
    return ((_httpCode >= 1 && _httpCode < 100) || (_httpCode >= 500 && _httpCode < 600)) ? YES : NO;
}

- (NSString *)getHTTPErrorMessage {
    if (!_isOnline) {
        return NSLocalizedString(@"alert_nonetwork_message", @"");
    }
//    if (self.connectionError != nil) {
//        return NSLocalizedString(@"server_failure_message", @"");
//    }
    return [NSHTTPURLResponse localizedStringForStatusCode:self.httpCode];
}

- (BOOL)isStatusSuccess {
    return YES;
//    if (_jobj == nil) return NO;
//    NSDictionary *dict = (NSDictionary *)_jobj;
//    if ([dict objectForKey:@"status"] == nil || [[dict objectForKey:@"status"] objectForKey:@"code"] == nil) return NO;
//    int code = [[[dict objectForKey:@"status"] objectForKey:@"code"] intValue];
//    return (code == 200);
}

- (id)getJsonObject {
    return _jobj;
}

- (BOOL)isNotAuthorized {
//    if (_jobj == nil) return NO;
//    
//    NSDictionary *dict = (NSDictionary *)_jobj;
//    int status = [[dict objectForKey:@"status"] intValue];
//    return (status == 401) ? YES : NO;
    return (self.httpCode == 401);
}

- (void)parseJsonData:(NSData *)jsonData {
    if (jsonData.length == 0) return;
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        DLog(@"data is informal: %@", error);
        return;
    }
    self.jobj = jsonObject;
}

/**
 * The function will parse result to an array or dictionary.
 */
- (id)getParsedResult {
    return nil;
}

- (id)parseDataForClassName:(NSString *)aClassName {
    id result = nil;
    if (_jobj == nil || [_jobj isKindOfClass:[NSNull class]]) return result;
    Class class;
    if ([_jobj isKindOfClass:[NSArray class]]) {
        //assume that it contain dictionary
        result = [NSMutableArray array];
        for (id child in _jobj) {
            class = NSClassFromString(aClassName);
            if (class) {
                id obj = [[class alloc] initWithDictionary:child];
                [result addObject:obj];
            }
        }
    }
    return result;
}

- (id)parseDataForClassName:(NSString *)aClassName list:(NSArray *)list {
    id result = nil;
    Class class;
    if (list.count > 0) {
        //assume that it contain dictionary
        result = [NSMutableArray array];
        for (id child in list) {
            class = NSClassFromString(aClassName);
            if (class) {
                id obj = [[class alloc] initWithDictionary:child];
                [result addObject:obj];
            }
        }
    }
    return result;
}

- (void)printHttpResponse {
    DLog(@"statusCode=%ld. stringForStatusCode=%@", (long)self.httpCode, [NSHTTPURLResponse localizedStringForStatusCode:self.httpCode]);
}
@end