//
//  Request.h
//  REP
//
//  Created by Phan Nam on 8/5/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _REQUEST_TYPE {
    RQ_NOCACHE = 1,
    RQ_GETCACHEFIRST = 2,
    RQ_GETCACHEIFFAILED = 4,
    RQ_SAVEDATA = 8
} REQUEST_TYPE;

typedef enum _CACHETYPE {
    CT_RESPONSE,
    CT_THUMBNAIL
} CACHETYPE;
@interface Request : NSObject
@property (nonatomic, strong)   NSString                *method;
@property (nonatomic, strong)   NSString                *service;
@property (nonatomic, strong)   NSString                *entry;
@property (nonatomic, strong)   NSString                *extFolder;
@property (nonatomic, strong)   NSString                *trailingParam;
@property (nonatomic, assign)   BOOL                    shouldFollowRedirect;
@property (nonatomic, assign)   REQUEST_TYPE            rqType;
@property (nonatomic, assign)   CACHETYPE               cacheType;
@property (nonatomic, assign)   BOOL                    shouldSilentLogin;
@property (nonatomic, assign)   BOOL                    shouldAddAccesToken;
@property (nonatomic, retain)   NSMutableDictionary     *paramDict;
@property (nonatomic, strong)   NSData                  *customBody;
@property (nonatomic, assign)   BOOL                    shouldPrintLog;

- (BOOL)hasBody;
- (void)addParameter:(NSString *)name value:(id)val;
- (NSData *)getBodyOfRequestInJson;
- (NSString *)getTargetRequestURL;
- (void)setAdditionalHeaderName:(NSString *)name value:(NSString *)val;
- (NSDictionary *)getAdditionalHeaders;
- (NSString *)getTargetKeyForRequest;
- (void)setCustomUrl:(NSString *)customUrl;
@end
