//
//  DownloadManager.h
//  Ethenic
//
//  Created by Phan Nam on 9/27/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"
#import "DownloadProtocol.h"
#import "Constants.h"
#import "Request.h"

@interface DownloadManager : BaseObject
+ (DownloadManager *)shareInstance;
- (void)removeListener:(id<DownloadProtocol>)listener;
- (void)cancelThreadsForListener:(id<DownloadProtocol>)listener;
- (void)downloadPhotoUrl:(NSString *)photoUrl delegate:(id<DownloadProtocol>)aDelegate;
- (void)downloadPhotoUrl:(NSString *)photoUrl processImage:(PROCESSIMAGE)processType delegate:(id<DownloadProtocol>)aDelegate;
- (UIImage *)getCachedImageForUrl:(NSString *)url;
- (void)saveCachedImage:(NSData *)data url:(NSString *)url;
- (BOOL)checkExistCacheImageForUrl:(NSString *)url;
@end
