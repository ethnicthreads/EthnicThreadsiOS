//
//  UIImageView+Custom.m
//  Saleshood
//
//  Created by Phan Nam on 10/16/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "UIImageView+Custom.h"
#import "DownloadManager.h"
#import "Categories.h"

static const char *kDownloadingUrlARKey =  "kDownloadingUrlARKey";

@implementation UIImageView (Custom)

//@dynamic processImgType;

- (void)setDownloadingUrl:(NSString *)aUrl {
    objc_setAssociatedObject(self,
                             kDownloadingUrlARKey, aUrl,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)getDownloadingUrl {
    return objc_getAssociatedObject(self, kDownloadingUrlARKey);
}

- (void)setCategoryDelegate:(id)categoryDelegate {
    id obj = [self categoryDelegate];
    if (obj == categoryDelegate) return;
    @synchronized(self) {
        objc_setAssociatedObject(self, "cbDelegateARKey", categoryDelegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (id)categoryDelegate {
    id obj = nil;
    @synchronized(self) {
        obj = objc_getAssociatedObject(self, "cbDelegateARKey");
    }
    return obj;
}

- (void)dealloc {
    [self setDownloadingUrl:nil];
    [self setCategoryDelegate:nil];
}

- (void)loadImageForUrl:(NSString *)url {
    [self loadImageForUrl:url type:IMAGE_CROPCENTER defaultImage:nil];
}

- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type {
    [self loadImageForUrl:url type:type defaultImage:nil];
}

- (void)loadImageForUrl:(NSString *)url defaultImage:(UIImage *)defaultImage {
    [self loadImageForUrl:url type:IMAGE_CROPCENTER defaultImage:defaultImage];
}

- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type defaultImage:(UIImage *)defaultImage {
    //self.processImgType = [NSNumber numberWithInt:type];
    NSString *cachedUrl = [self getDownloadingUrl];
    if (defaultImage && (self.image == nil || !cachedUrl || ![cachedUrl isEqual:url])) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = nil;
            switch (type) {
                case IMAGE_CROPCENTER:
                    image = [defaultImage cropCenterToSize:self.frame.size];
                    break;
                case IMAGE_SCALE:
                    image = [defaultImage scaleToSize:self.frame.size];
                    break;
                default:
                    image = defaultImage;
                    break;
            }
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    self.image = image;
                });
            }
        });
    }
    [[DownloadManager shareInstance] cancelThreadsForListener:self];
    if (url.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *cachedImage = [[DownloadManager shareInstance] getCachedImageForUrl:url];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (cachedImage) {
                    [self didFinishDownloadingImage:cachedImage url:url processImageType:type];
                }
                else {
                    [[DownloadManager shareInstance] downloadPhotoUrl:url processImage:type delegate:self];
                }
            });
        });
    }
}

- (void)cancel {
    //[[DownloadManager shareInstance] cancelThreadsForListener:self];
    [[DownloadManager shareInstance] removeListener:self];
    [self setCategoryDelegate:nil];
}

- (void)quit {
    //[[DownloadManager shareInstance] cancelThreadsForListener:self];
    [[DownloadManager shareInstance] removeListener:self];
    [self setCategoryDelegate:nil];
    [self setDownloadingUrl:nil];
}

/*
 - (void)loadProfileImageForUrl:(NSString *)url {
 [self loadProfileImageForUrl:url processImage:IMAGE_CROPCENTER];
 }
 
 - (void)loadProfileImageForUrl:(NSString *)url processImage:(PROCESSIMAGE)processImageType {
 self.image = nil;
 [[DownloadManager shareInstance] cancelThreadsForListener:self];
 if (url != nil) {
 [[DownloadManager shareInstance] downloadProfilePhotoUrl:url processImage:processImageType delegate:self];
 }
 }
 */
#pragma mark - Download protocol
- (void)didFinishDownloadingImage:(UIImage *)downloadedImage url:(NSString *)downloadedUrl processImageType:(PROCESSIMAGE)processType {
    if ([self.categoryDelegate respondsToSelector:@selector(cbImageView:didFinishDownloadingImage:)]) {
        [self.categoryDelegate cbImageView:self didFinishDownloadingImage:downloadedImage];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = nil;
            switch (processType) {
                case IMAGE_CROPCENTER:
                    image = [downloadedImage cropCenterToSize:self.frame.size];
                    break;
                case IMAGE_SCALE:
                    image = [downloadedImage scaleToSize:self.frame.size];
                    break;
                default:
                    image = downloadedImage;
                    break;
            }
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    self.image = image;
                });
            }
        });
        
    }
    if ([self.categoryDelegate respondsToSelector:@selector(cbImageView:didFinishUpdatingImageFromUrl:)]) {
        [self.categoryDelegate cbImageView:self didFinishUpdatingImageFromUrl:downloadedUrl];
    }
    if ([self.categoryDelegate respondsToSelector:@selector(cbImageView:didFinishDownloadingImage:downloadFailUrl:)]) {
        [self.categoryDelegate cbImageView:self didFinishDownloadingImage:downloadedImage downloadFailUrl:downloadedUrl];
    }
    [self setDownloadingUrl:downloadedUrl];
}

- (void)didHaveErrorWhileDownloadPhotoAtUrl:(NSString *)downloadedUrl {
    if ([self.categoryDelegate respondsToSelector:@selector(cbImageView:downloadFailUrl:)]) {
        [self.categoryDelegate cbImageView:self downloadFailUrl:downloadedUrl];
    }
}
@end
