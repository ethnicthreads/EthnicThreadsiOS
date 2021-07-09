//
//  DownloadManager.m
//  Ethenic
//
//  Created by Phan Nam on 9/27/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Categories.h"
#import "DownloadManager.h"
#import "OperationManager.h"
#import "CloudManager.h"
#import "CachedManager.h"
#import "Utils.h"

@interface DownloadManager()
@property (nonatomic, strong) NSMutableDictionary       *listenerDict;
@property (nonatomic, strong) Request                   *cachedRequest;
@end

@implementation DownloadManager
+ (DownloadManager *)shareInstance {
    static DownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DownloadManager alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _listenerDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.cachedRequest = [[Request alloc] init];
        self.cachedRequest.service = @"";
        self.cachedRequest.entry = @"";
        self.cachedRequest.method = @"GET";
        self.cachedRequest.rqType = RQ_GETCACHEFIRST | RQ_SAVEDATA;
    }
    return self;
}

- (void)addListener:(id<DownloadProtocol>)listener thread:(id<OperationProtocol>)thread{
    NSString *key = [NSString stringWithFormat:@"%p", listener];
    if ([_listenerDict objectForKey:key] == nil) {
        @synchronized(self) {
            if ([_listenerDict objectForKey:key] == nil) {
                [_listenerDict setValue:[NSMutableArray array] forKey:key];
            }
        }
    }
    NSMutableArray *arr = [_listenerDict objectForKey:key];
    [arr addObject:thread];
}

- (void)removeListener:(id<DownloadProtocol>)listener {
    NSString *key = [NSString stringWithFormat:@"%p", listener];
    if ([_listenerDict objectForKey:key] != nil) {
        @synchronized(self) {
            if ([_listenerDict objectForKey:key] != nil) {
                NSMutableArray *arr = [_listenerDict objectForKey:key];
                id<OperationProtocol> thread;
                for (int i = 0; i < arr.count; i++) {
                    thread = [arr objectAtIndex:i];
                    [thread cancel];
                }
                [_listenerDict removeObjectForKey:key];
            }
        }
    }
}

- (void)removeThread:(id<OperationProtocol>)thread ofListener:(id<DownloadProtocol>)listener {
    NSString *key = [NSString stringWithFormat:@"%p", listener];
    if ([_listenerDict objectForKey:key] != nil) {
        @synchronized(self) {
            if ([_listenerDict objectForKey:key] != nil) {
                [thread cancel];
                NSMutableArray *arr = [_listenerDict objectForKey:key];
                [arr removeObject:thread];
                if (arr.count == 0) {
                    [_listenerDict removeObjectForKey:key];
                }
            }
        }
    }
}

- (void)cancelThreadsForListener:(id<DownloadProtocol>)listener {
    NSString *key = [NSString stringWithFormat:@"%p", listener];
    if ([_listenerDict objectForKey:key] != nil) {
        @synchronized(self) {
            if ([_listenerDict objectForKey:key] != nil) {
                NSMutableArray *arr = [_listenerDict objectForKey:key];
                id<OperationProtocol> thread;
                for (int i = 0; i < arr.count; i++) {
                    thread = [arr objectAtIndex:i];
                    [thread cancel];
                }
            }
        }
    }
}

- (void)downloadPhotoUrl:(NSString *)photoUrl delegate:(id<DownloadProtocol>)aDelegate {
    [self downloadPhotoUrl:photoUrl processImage:IMAGE_CROPCENTER delegate:aDelegate];
}

- (void)downloadPhotoUrl:(NSString *)photoUrl processImage:(PROCESSIMAGE)processType delegate:(id<DownloadProtocol>)aDelegate {
    NSArray *param;
    param = @[photoUrl, aDelegate, [NSNumber numberWithInt:processType]];
    id<OperationProtocol> thread = [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeDownloadPhotoUrl:thread:) argument:param];
    [self addListener:aDelegate thread:thread];
}

- (UIImage *)getCachedImageForUrl:(NSString *)url {
    NSData *data = [[CachedManager sharedInstance] getCachedDataForKey:[url md5] type:CT_THUMBNAIL];
    return (data == nil) ? nil : [UIImage imageWithData:data];
}

- (void)saveCachedImage:(NSData *)data url:(NSString *)url {
    if (data.length > 0) {
        [[CachedManager sharedInstance] cacheData:data key:[url md5] type:CT_THUMBNAIL];
    }
}

- (BOOL)checkExistCacheImageForUrl:(NSString *)url {
    return [[CachedManager sharedInstance] checkExistCachedDataForKey:[url md5] type:CT_THUMBNAIL];
}

- (void)deleteCacheImageForUrl:(NSString *)url {
    
}
//not used
/*
 - (void)deleteCachedImageForUrl:(NSString *)url {
 Request *request = [[Request alloc] init];
 request.service = @"";
 request.entry = @"";
 request.method = @"GET";
 request.shouldPrintLog = NO;
 request.rqType = RQ_GETCACHEIFFAILED | RQ_SAVEDATA;
 [request setCustomUrl:url];
 [[CacheManager shareInstance] deleteCachedDataForRequest:request];
 }
 
 
 - (void)downloadProfilePhotoUrl:(NSString *)photoUrl processImage:(PROCESSIMAGE)processType delegate:(id<DownloadProtocol>)aDelegate {
 NSArray *param;
 param = @[photoUrl, aDelegate, [NSNumber numberWithInt:processType]];
 id<OperationProtocol> thread = [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeDownloadProfilePhotoUrl:thread:) argument:param];
 [self addListener:aDelegate thread:thread];
 }
 */
#pragma mark - Private
- (void)executeDownloadPhotoUrl:(NSArray *)params thread:(id<OperationProtocol>)threadObj {
    NSString *url = [params objectAtIndex:0];
    id<DownloadProtocol> downloadDelegate = [params objectAtIndex:1];
    PROCESSIMAGE processType = [[params objectAtIndex:2] intValue];
    if ([url hasPrefix:@"http"]) {
        Response *response = [CloudManager downloadPhotoWithUrl:url];
        if ([threadObj isCancelled]) {
            if ([response isHTTPSuccess] && response.pureResponseData.length > 0) {
                [self saveCachedImage:response.pureResponseData url:url];
            }
            [threadObj releaseOperation];
            return;
        }
        else {
            if ([response isHTTPSuccess] && response.pureResponseData.length > 0) {
                [self saveCachedImage:response.pureResponseData url:url];
                if ([downloadDelegate respondsToSelector:@selector(didFinishDownloadingImage:url:processImageType:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [downloadDelegate didFinishDownloadingImage:[UIImage imageWithData:response.pureResponseData] url:url processImageType:processType];
                    });
                }
            }
            else if ([downloadDelegate respondsToSelector:@selector(didHaveErrorWhileDownloadPhotoAtUrl:)]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [downloadDelegate didHaveErrorWhileDownloadPhotoAtUrl:url];
                });
            }
        }
    }
    else if ([url hasPrefix:@"file"]) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if ([downloadDelegate respondsToSelector:@selector(didFinishDownloadingImage:url:processImageType:)]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [downloadDelegate didFinishDownloadingImage:[UIImage imageWithData:data] url:url processImageType:processType];
            });
        }
    }
    [self removeThread:threadObj ofListener:downloadDelegate];
    [threadObj releaseOperation];
}

//not used
/*
 - (void)executeDownloadProfilePhotoUrl:(NSArray *)params thread:(id<OperationProtocol>)threadObj {
 NSString *url = [params objectAtIndex:0];
 id<DownloadProtocol> downloadDelegate = [params objectAtIndex:1];
 PROCESSIMAGE processType = [[params objectAtIndex:2] intValue];
 if ([url hasPrefix:@"http"]) {
 Request *request = [[Request alloc] init];
 request.service = @"";
 request.entry = @"";
 request.method = @"GET";
 request.shouldPrintLog = NO;
 request.rqType = RQ_GETCACHEIFFAILED | RQ_SAVEDATA;
 [request setCustomUrl:url];
 Response *response = [CloudManager downloadPhotoWithRequest:request];
 if ([threadObj isCancelled]) {
 [threadObj releaseOperation];
 return;
 }
 if ([response isHTTPSuccess]) {
 if ([downloadDelegate respondsToSelector:@selector(didFinishDownloadingImage:url:processImageType:)]) {
 [Utils dispatchToMainQueue:^{
 [downloadDelegate didFinishDownloadingImage:[UIImage imageWithData:response.pureResponseData] url:url processImageType:processType];
 }];
 }
 }
 else if ([downloadDelegate respondsToSelector:@selector(didHaveErrorWhileDownloadPhotoAtUrl:)]) {
 [Utils dispatchToMainQueue:^{
 [downloadDelegate didHaveErrorWhileDownloadPhotoAtUrl:url];
 }];
 }
 }
 else if ([url hasPrefix:@"file"]) {
 id<DownloadProtocol> downloadDelegate = [params objectAtIndex:1];
 NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
 if ([downloadDelegate respondsToSelector:@selector(didFinishDownloadingImage:url:processImageType:)]) {
 [Utils dispatchToMainQueue:^{
 [downloadDelegate didFinishDownloadingImage:[UIImage imageWithData:data] url:url processImageType:processType];
 }];
 }
 }
 [threadObj releaseOperation];
 }*/
@end
