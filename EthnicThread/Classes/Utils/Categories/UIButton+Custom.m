//
//  UIButton+Custom.m
//  EthnicThread
//
//  Created by Nam Phan on 12/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UIButton+Custom.h"
#import "DownloadManager.h"
#import "Categories.h"

static const char *kButtonDownloadingUrlARKey =  "kButtonDownloadingUrlARKey";
@implementation UIButton (Custom)

//@dynamic processImgType;

- (void)setDownloadingUrl:(NSString *)aUrl {
    objc_setAssociatedObject(self,
                             kButtonDownloadingUrlARKey, aUrl,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)getDownloadingUrl {
    return objc_getAssociatedObject(self, kButtonDownloadingUrlARKey);
}

- (void)setCategoryDelegate:(id)categoryDelegate {
    id obj = [self categoryDelegate];
    if (obj == categoryDelegate) return;
    @synchronized(self) {
        objc_setAssociatedObject(self, "cbButtonDelegateARKey", categoryDelegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (id)categoryDelegate {
    id obj = nil;
    @synchronized(self) {
        obj = objc_getAssociatedObject(self, "cbButtonDelegateARKey");
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
    NSString *cachedUrl = [self getDownloadingUrl];
    if (defaultImage && ([self imageForState:UIControlStateNormal] == nil || !cachedUrl || ![cachedUrl isEqual:url])) {
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
                    [self setBackgroundImage:image forState:UIControlStateNormal];
                });
            }
        });
        
    }
    [[DownloadManager shareInstance] cancelThreadsForListener:self];
    if (url.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *cachedImage = [[DownloadManager shareInstance] getCachedImageForUrl:url];
            if (cachedImage) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self didFinishDownloadingImage:cachedImage url:url processImageType:type];
                });
            }
            else {
                [[DownloadManager shareInstance] downloadPhotoUrl:url processImage:type delegate:self];
            }
        });
    }
}

- (void)cancel {
    [[DownloadManager shareInstance] removeListener:self];
    [self setCategoryDelegate:nil];
}

- (void)quit {
    [[DownloadManager shareInstance] removeListener:self];
    [self setCategoryDelegate:nil];
    [self setDownloadingUrl:nil];
}
#pragma mark - Download protocol
- (void)didFinishDownloadingImage:(UIImage *)downloadedImage url:(NSString *)downloadedUrl processImageType:(PROCESSIMAGE)processType {
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
                [self setBackgroundImage:image forState:UIControlStateNormal];
            });
        }
    });
    [self setDownloadingUrl:downloadedUrl];
}

- (void)didHaveErrorWhileDownloadPhotoAtUrl:(NSString *)downloadedUrl {
    
}
@end
