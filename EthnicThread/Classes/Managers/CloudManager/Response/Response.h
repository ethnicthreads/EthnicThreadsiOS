//
//  Response.h
//  REP
//
//  Created by Phan Nam on 8/5/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Response : NSObject
@property (nonatomic, assign)   BOOL                isSucc;
@property (nonatomic, assign)   BOOL                shouldParseResponse;
@property (nonatomic, assign)   BOOL                isOnline;
@property (nonatomic, assign)   BOOL                isPing;
@property (nonatomic, retain)   NSData              *pureResponseData;
@property (nonatomic, assign)   NSInteger			httpCode;
@property (nonatomic, retain)   NSDictionary        *responseHeaders;
@property (nonatomic, retain)   NSError             *resError;
@property (nonatomic, copy)     NSString            *codeReturn;
@property (nonatomic, copy)     NSString            *errCodeReturn;
@property (nonatomic, retain) id        jobj;

- (BOOL)shouldOnlyGetResponse;
- (BOOL)isHTTPSuccess;
- (BOOL)isHTTPClientError;
- (BOOL)isHTTPServerError;
- (BOOL)isStatusSuccess;
- (NSString *)getHTTPErrorMessage;
- (id)getJsonObject;
- (BOOL)isNotAuthorized;
- (void)parseJsonData:(NSData *)jsonData;
- (id)getParsedResult;
- (id)parseDataForClassName:(NSString *)aClassName;
- (id)parseDataForClassName:(NSString *)aClassName list:(NSArray *)list;
- (void)printHttpResponse;
@end
