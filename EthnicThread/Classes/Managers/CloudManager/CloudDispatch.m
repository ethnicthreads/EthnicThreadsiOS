//
//  CloudDispatch.m
//  REP
//
//  Created by Phan Nam on 8/3/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "CloudDispatch.h"
#import "Constants.h"
#import "AppManager.h"
#import "StreamingMultipartFormData.h"
#import "QueryStringPair.h"
#import "UserManager.h"
#import "OperationManager.h"
#import "AppDelegate.h"
#import "CachedManager.h"

@interface CloudDispatch() {
    NSObject *loginLock;//used to lock thread when one thread is doing silent login.
    int    silentLoginState;//0 - not silent login yet, 1 - silent login succ, 2 - silent login failed.
}

@end

@implementation CloudDispatch
+ (CloudDispatch *)shareInstance {
    static CloudDispatch *reqinstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reqinstance = [[CloudDispatch alloc] init];
    });
    return reqinstance;
}

- (id)init {
    self = [super init];
    if (self) {
        loginLock = [[NSObject alloc] init];
        silentLoginState = 0;
    }
    return self;
}

- (void)dispatchRequest:(Request *)request response:(Response *)response {
    @try {
        //log
        NSMutableString *log = [NSMutableString stringWithString:@""];
        NSMutableURLRequest *URLRequest;
        if ([request isKindOfClass:[ETMultipartRequest class]]) {
            URLRequest = [self createMultipartFormRequest:(ETMultipartRequest *)request response:response log:log];
        }
        else {
            URLRequest = [self createURLRequest:request response:response log:log];
        }
        if (URLRequest == nil) return;
        
        //connect to server
        ConnectionHandler *conHandler = [[ConnectionHandler alloc] init];
        conHandler.currentRequest = request;
        conHandler.currentResponse = response;
        if (request.shouldPrintLog) DLog(@"request:%@", log);
        if ([conHandler shouldSendRequestToServer]) {
            [conHandler connectToServerWithRequest:URLRequest];
            
            if ([conHandler.currentResponse isNotAuthorized] && conHandler.currentRequest.shouldSilentLogin) {
                //lock
                @synchronized(loginLock) {
                    if (silentLoginState == 0) {
                        //hasn't logged in silent mode
                        BOOL result = [[UserManager sharedInstance] silentReLogin];
                        if (result) {
                            //login success, app has new authentication_key
                            silentLoginState = 1;
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            [appDelegate registerForPushNotifications];
                        }
                        else {
                            silentLoginState = 2;
                            //show alert
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                [appdelegate logOut];
                            });
                            //stop all threads
                            [[OperationManager shareInstance] stopAllThreads];
                        }
                        //enable timer to reset silent login state
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(resetSilentLoginState:) userInfo:nil repeats:NO];
                        });
                    }
                }
                if (silentLoginState == 1) {
                    if ([request isKindOfClass:[ETMultipartRequest class]]) {
                        URLRequest = [self createMultipartFormRequest:(ETMultipartRequest *)request response:response log:log];
                    }
                    else {
                        URLRequest = [self createURLRequest:request response:response log:log];
                    }
                    [conHandler connectToServerWithRequest:URLRequest];
                }
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"RequestDispatcher - dispatchRequest throw exception:%@", e);
    }
}

- (void)resetSilentLoginState:(id)sender {
    silentLoginState = 0;
}

#pragma mark - Internal methods
- (void)setupRequestHeaders:(NSMutableURLRequest *)request additionalHeaders:(NSDictionary *)headers {
    NSArray *keys = [headers allKeys];
    for (NSString *key in keys) {
        //[request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        [request addValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    [request setValue:@"" forHTTPHeaderField:@"Cookie"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
}

- (NSMutableURLRequest *)createURLRequest:(Request *)request response:(Response *)response log:(NSMutableString *)log {
    NSString *strUrl = [request getTargetRequestURL];
    if (strUrl == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Target request URL is nil" forKey:NSLocalizedDescriptionKey];
        response.resError = [NSError errorWithDomain:@"Ethnic Thread" code:100 userInfo:errorDetail];
        return nil;
    }
    else if (strUrl.length > 2048) {
        response.httpCode = 0;
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"URL to request directions exceeds 2048 characters" forKey:NSLocalizedDescriptionKey];
        response.resError = [NSError errorWithDomain:@"Ethnic Thread" code:100 userInfo:errorDetail];
        return nil;
    }
    NSURL *URL = [NSURL URLWithString: strUrl];
    if (URL == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[NSString stringWithFormat:@"Could not initiate NSURL for target %@", strUrl] forKey:NSLocalizedDescriptionKey];
        response.resError = [NSError errorWithDomain:@"Ethnic Thread" code:101 userInfo:errorDetail];
        return nil;
    }
    //log
    [log appendFormat:@"RequestDispatcher - dispatchRequest for target URL:%@\n", [URL absoluteString]];
    
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 60];
    
    [log appendFormat:@"\tMethod : %@\n", request.method];
    if ([request hasBody]) {
        [URLRequest setHTTPMethod:request.method];
        NSData *body = [request getBodyOfRequestInJson];
        [log appendFormat:@"\tBodyMsg : %@\n", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]];
        //            if ([Configuration applicationSupportGZIPCommunication]) {
        //                [URLRequest setHTTPBody:[body gzipDeflate]];
        //                [URLRequest setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        //            }
        //            else
        {
            [URLRequest setHTTPBody:body];
        }
    }
    else {
        [URLRequest setHTTPMethod:request.method];
    }
    
    //set up request
    [self setupRequestHeaders:URLRequest additionalHeaders:[request getAdditionalHeaders]];

    if (request.shouldAddAccesToken) {
        [URLRequest setValue:[[UserManager sharedInstance] getAccount].access_token forHTTPHeaderField:@"token"];
    }
    return URLRequest;
}

- (NSMutableURLRequest *)createMultipartFormRequest:(ETMultipartRequest *)request response:(Response *)response log:(NSMutableString *)log {
    NSParameterAssert(request.method);
    NSParameterAssert(![request.method isEqualToString:@"GET"] && ![request.method isEqualToString:@"HEAD"]);
    NSString *strUrl = [request getTargetRequestURL];
    if (strUrl == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Target request URL is nil" forKey:NSLocalizedDescriptionKey];
        response.resError = [NSError errorWithDomain:@"Ethnic Thread" code:100 userInfo:errorDetail];
        return nil;
    }
    else if (strUrl.length > 2048) {
        response.httpCode = 0;
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"URL to request directions exceeds 2048 characters" forKey:NSLocalizedDescriptionKey];
        response.resError = [NSError errorWithDomain:@"Ethnic Thread" code:100 userInfo:errorDetail];
        return nil;
    }
    NSURL *URL = [NSURL URLWithString: strUrl];
    if (URL == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[NSString stringWithFormat:@"Could not initiate NSURL for target %@", strUrl] forKey:NSLocalizedDescriptionKey];
        response.resError = [NSError errorWithDomain:@"Ethnic Thread" code:101 userInfo:errorDetail];
        return nil;
    }
    //log
    [log appendFormat:@"RequestDispatcher - createMultipartFormRequest for target URL:%@\n", [URL absoluteString]];
    
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:180];
    [URLRequest setHTTPMethod:request.method];
    
    __block StreamingMultipartFormData *formData = [[StreamingMultipartFormData alloc] initWithURLRequest:URLRequest stringEncoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = [request paramDict];
    if (parameters) {
        for (QueryStringPair *pair in QueryStringPairsFromDictionary(parameters)) {
            NSData *data = nil;
            if ([pair.value isKindOfClass:[NSData class]]) {
                data = pair.value;
            } else if ([pair.value isEqual:[NSNull null]]) {
                data = [NSData data];
            } else {
                data = [[pair.value description] dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (data) {
                [formData appendPartWithFormData:data name:[pair.field description]];
            }
        }
    }
    
    NSError *error;
    if (request.multiparts) {
        for (Multipart *multipart in request.multiparts) {
            if ([multipart isKindOfClass:[MultipartData class]]) {
                [formData appendPartWithFormData:[(MultipartData *)multipart data] name:multipart.name];
            }
            else if ([multipart isKindOfClass:[MultipartFileURL class]]) {
                if (multipart.mimeType != nil) {
                    [formData appendPartWithFileURL:[(MultipartFileURL *)multipart fileURL] name:multipart.name fileName:[(MultipartFileURL *)multipart fileName] mimeType:multipart.mimeType error:&error];
                    if (error) NSLog(@"error: %@", error);
                }
                else {
                    [formData appendPartWithFileURL:[(MultipartFileURL *)multipart fileURL] name:multipart.name error:&error];
                    if (error) NSLog(@"error: %@", error);
                }
            }
        }
    }
    
    NSMutableURLRequest *multipartURLRequest = [formData requestByFinalizingMultipartFormData];
    if (request.shouldAddAccesToken) {
        [multipartURLRequest setValue:[[UserManager sharedInstance] getAccount].access_token forHTTPHeaderField:@"token"];
    }
    return multipartURLRequest;
}
@end

/*******************************
 This class is used to manage http request
 ******************************/

@interface ConnectionHandler()
@property (nonatomic, retain) NSMutableData         *responseData;
@property (nonatomic, retain) NSURLConnection       *urlConnection;
@property (nonatomic, retain) NSTimer               *timeout;
@end

@implementation ConnectionHandler

- (id)init {
    self = [super init];
    if (self != nil) {
        self.responseData = [NSMutableData data];
        _done = NO;
    }
    return self;
}

- (BOOL)shouldSendRequestToServer {
    if ((self.currentRequest.rqType & RQ_GETCACHEFIRST) == 0) return YES;
    NSData *data = [[CachedManager sharedInstance] getCachedDataForKey:[self.currentRequest getTargetKeyForRequest] type:self.currentRequest.cacheType];
    if (data.length == 0) return YES;
    
    _currentResponse.httpCode = 200;
    //always save response
    _currentResponse.pureResponseData = data;
    if (_currentResponse.shouldParseResponse) {
        [self.currentResponse parseJsonData:data];
    }
    return NO;
}

- (void)connectToServerWithRequest:(NSURLRequest *)aUrlRequest {
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:aUrlRequest delegate:self startImmediately:NO];
    if (![self.currentRequest isKindOfClass:[ETMultipartRequest class]]) {
        self.timeout = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(checkResponseTimeout:) userInfo:nil repeats:NO];
    }
    
    self.urlRequest = aUrlRequest;
    DLog(@"Request headers %@ %@", self.urlRequest.URL, [[aUrlRequest allHTTPHeaderFields] description]);
    //start
    _done = NO;
    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.urlConnection start];
    
    if (![self.urlRequest isKindOfClass:[ETMultipartRequest class]]) {
        while(!_done) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
    }
    
    [self.timeout invalidate];
}
#pragma mark - Private
- (void)checkResponseTimeout:(NSTimer *)aTimer {
    [self.urlConnection cancel];
	_done = YES;
}
#pragma mark - NSURLConnection Delegates
- (BOOL)connection:(NSURLConnection *)conn canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    [_responseData setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //save headers - it may be used in the future
    _currentResponse.httpCode = [httpResponse statusCode];
    _currentResponse.responseHeaders = [httpResponse allHeaderFields];
    
    if ([_currentResponse shouldOnlyGetResponse]) {
        [conn cancel];
        _done = YES;
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    DLog(@"didFailWithError for request: %@:\nError:%@.", self.urlRequest, error);
    if (_currentRequest.rqType & RQ_GETCACHEIFFAILED) {
        NSData *data = [[CachedManager sharedInstance] getCachedDataForKey:[self.currentRequest getTargetKeyForRequest] type:self.currentRequest.cacheType];
        if (data.length == 0) return;
        
        _currentResponse.httpCode = 200;
        //always save response
        _currentResponse.pureResponseData = data;
        if (_currentResponse.shouldParseResponse) {
            [self.currentResponse parseJsonData:data];
        }
    }
    else {
        _currentResponse.resError = error;
        if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut) {
            _currentResponse.isOnline = NO;
        }
    }
    _done = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    _currentResponse.pureResponseData = [NSData dataWithData:_responseData];
    if (_currentRequest.shouldPrintLog)
        DLog(@"response for request: %@:\n\n%@\n\n. \n\nHttp code: %ld", self.urlRequest, [[NSString alloc] initWithData:_currentResponse.pureResponseData encoding:NSUTF8StringEncoding], (long)_currentResponse.httpCode);
    if (([_currentResponse isHTTPSuccess] || [_currentResponse isHTTPClientError]) &&
        [_responseData length] > 0 && _currentResponse.shouldParseResponse) {
        [self.currentResponse parseJsonData:_responseData];
    }
    
    if ((self.currentRequest.rqType & RQ_SAVEDATA) &&
        [self.currentResponse isHTTPSuccess] && [self.currentResponse isStatusSuccess]) {
        if (self.currentResponse.jobj != nil) {
            [[CachedManager sharedInstance] cacheData:self.responseData key:[self.currentRequest getTargetKeyForRequest] type:self.currentRequest.cacheType];
        }
    }
    _done = YES;
}

- (NSURLRequest *)connection:(NSURLConnection *)conn willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (_currentRequest.shouldFollowRedirect) return request;
	if (response) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary *allHeaders = [httpResponse allHeaderFields];
        
		if ([httpResponse statusCode] >= 301 && [httpResponse statusCode] <= 302 &&
            [allHeaders objectForKey:@"Location"] != nil) {
            _currentResponse.httpCode = [httpResponse statusCode];
            _currentResponse.responseHeaders = [NSDictionary dictionaryWithDictionary:allHeaders];
            
            [conn cancel];
            _done = YES;
            return nil;
        }
	}
	return request;
}

@end
