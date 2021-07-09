//
//  CachedManager.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/22/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Request.h"

@interface CachedManager : NSObject

+ (CachedManager *)sharedInstance;
#pragma mark - Cache
- (void)cacheData:(NSData *)data key:(NSString *)key type:(CACHETYPE)cacheType;
- (NSData *)getCachedDataForKey:(NSString *)key type:(CACHETYPE)cacheType;
- (BOOL)checkExistCachedDataForKey:(NSString *)key type:(CACHETYPE)cacheType;
- (NSString *)cacheTempJPEGImage:(UIImage *)image withFileName:(NSString *)fileName;
- (void)removeAllCachedTempImages;
- (void)clearCachedResponeData;
@end
