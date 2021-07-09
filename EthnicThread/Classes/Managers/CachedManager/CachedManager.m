//
//  CachedManager.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/22/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CachedManager.h"
#import "Categories.h"
#import "Utils.h"
#import "Constants.h"

@interface CachedManager()
@property (nonatomic, strong) NSString              *appCachedPath;
@property (nonatomic, strong) NSString              *cacheResponsePath;
@property (nonatomic, strong) NSString              *cacheThumbnailPath;
@property (nonatomic, strong) NSString              *cacheTempPath;
@end

@implementation CachedManager

+ (CachedManager *)sharedInstance {
    static CachedManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CachedManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        //init cache folder if not available
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSError *error = nil;
        self.appCachedPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Ethenic"];
        if (![filemanager fileExistsAtPath:self.appCachedPath]) {
            [filemanager createDirectoryAtPath:self.appCachedPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        self.cacheResponsePath = [self.appCachedPath stringByAppendingPathComponent:@"REQUEST_DATA"];
        if (![filemanager fileExistsAtPath:self.cacheResponsePath]) {
            [filemanager createDirectoryAtPath:self.cacheResponsePath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        //thumb
        self.cacheThumbnailPath = [self.appCachedPath stringByAppendingPathComponent:@"THUMBNAILCACHE"];
        if (![filemanager fileExistsAtPath:self.cacheThumbnailPath]) {
            [filemanager createDirectoryAtPath:self.cacheThumbnailPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        self.cacheTempPath = [self.appCachedPath stringByAppendingPathComponent:@"TEMPCACHE"];
        if (![filemanager fileExistsAtPath:self.cacheTempPath]) {
            [filemanager createDirectoryAtPath:self.cacheTempPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        [self clearCachedThumbnails:432000];// 432000 = 5 days
    }
    return self;
}

- (void)cacheData:(NSData *)data key:(NSString *)key type:(CACHETYPE)cacheType {
    if (cacheType == CT_RESPONSE) {
        [self writeData:data path:[self getResponsePathWithKey:key]];
    }
    else if (cacheType == CT_THUMBNAIL) {
        UIImage *image = [UIImage imageWithData:data];
        image = [image scaleByWidth:IMAGE_ITEM_WIDTH];
        data = UIImageJPEGRepresentation(image, 1.0);
        [self writeData:data path:[self getThumbnailPathWithKey:key]];
    }
}

- (NSData *)getCachedDataForKey:(NSString *)key type:(CACHETYPE)cacheType {
    if (cacheType == CT_RESPONSE) {
        return [self getSavedDataAtPath:[self getResponsePathWithKey:key]];
    }
    else if (cacheType == CT_THUMBNAIL) {
        return [self getSavedDataAtPath:[self getThumbnailPathWithKey:key]];
    }
    return nil;
}

- (BOOL)checkExistCachedDataForKey:(NSString *)key type:(CACHETYPE)cacheType {
    NSString *path = nil;
    if (cacheType == CT_RESPONSE) {
        path = [self getResponsePathWithKey:key];
    }
    else if (cacheType == CT_THUMBNAIL) {
        path = [self getThumbnailPathWithKey:key];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];;
    return [fileManager fileExistsAtPath:path];
}

#pragma mark - Private
- (NSString *)getResponsePathWithKey:(NSString *)key {
    return [_cacheResponsePath stringByAppendingPathComponent:key];
}

- (NSString *)getThumbnailPathWithKey:(NSString *)key {
    return [_cacheThumbnailPath stringByAppendingPathComponent:key];
}

- (NSString *)getCacheFolderPath:(NSString *)aFolder {
    NSString *cachedfolder = [self.appCachedPath stringByAppendingPathComponent:aFolder];
    //create extend folder if not exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cachedfolder]) {
        [fileManager createDirectoryAtPath:cachedfolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachedfolder;
}

- (NSData *)getSavedDataAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    NSError *error = nil;
    NSData *result = nil;
    
    @synchronized(self) {
        result = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
    }
    if (error) {
        result = nil;
    }
    return  result;
}

- (void)writeData:(NSData *)data path:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *guidesURL = [NSURL fileURLWithPath:path];
    BOOL success = [guidesURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if ([fileManager fileExistsAtPath:path]) {
        //delete it
        [fileManager removeItemAtPath:path error:&error];
    }
    @synchronized(self) {
        [data writeToFile:path atomically:YES];
    }
}

- (NSString *)cacheTempJPEGImage:(UIImage *)image withFileName:(NSString *)fileName {
    NSString *filePath = [self.cacheTempPath stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [data writeToFile:filePath atomically:YES];
    return filePath;
}

- (void)removeAllCachedTempImages {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *fileName in [fm contentsOfDirectoryAtPath:self.cacheTempPath error:&error]) {
        NSString *filePath = [self.cacheTempPath stringByAppendingPathComponent:fileName];
        [fm removeItemAtPath:filePath error:&error];
    }
}

- (void)clearCachedResponeData {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *fileName in [fm contentsOfDirectoryAtPath:self.cacheResponsePath error:&error]) {
        NSString *filePath = [self.cacheResponsePath stringByAppendingPathComponent:fileName];
        [fm removeItemAtPath:filePath error:&error];
    }
}

- (void)clearCachedThumbnails:(NSTimeInterval)periodicTime {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *fileName in [fm contentsOfDirectoryAtPath:self.cacheThumbnailPath error:&error]) {
        NSString *filePath = [self.cacheThumbnailPath stringByAppendingPathComponent:fileName];
        NSDictionary *file = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([file fileModificationDate].timeIntervalSince1970 + periodicTime < [[NSDate date] timeIntervalSince1970]) {
            [fm removeItemAtPath:filePath error:&error];
        }
    }
    
    NSDictionary *file = [[NSFileManager defaultManager] attributesOfItemAtPath:@"" error:NULL];
    [file fileSize];
}
@end
