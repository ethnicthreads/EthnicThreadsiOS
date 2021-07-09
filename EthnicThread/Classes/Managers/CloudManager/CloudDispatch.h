//
//  CloudDispatch.h
//  REP
//
//  Created by Phan Nam on 8/3/13.
//  Copyright (c) 2013 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Response.h"
#import "ETMultipartRequest.h"
#import "MultipartData.h"
#import "MultipartFileURL.h"

@interface CloudDispatch : NSObject
+ (CloudDispatch *)shareInstance;
- (void)dispatchRequest:(Request *)request response:(Response *)response;
@end

/*******************************
 This class is used to manage http request
 ******************************/
@interface ConnectionHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, assign) BOOL              done;
@property (nonatomic, retain) Request           *currentRequest;
@property (nonatomic, retain) Response          *currentResponse;
@property (nonatomic, retain) NSURLRequest      *urlRequest;

- (BOOL)shouldSendRequestToServer;
- (void)connectToServerWithRequest:(NSURLRequest *)aUrlRequest;

@end