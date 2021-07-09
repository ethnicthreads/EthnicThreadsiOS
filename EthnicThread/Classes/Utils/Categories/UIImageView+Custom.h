//
//  UIImageView+Custom.h
//  Ethenic
//
//  Created by Phan Nam on 10/16/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "DownloadProtocol.h"
#import "Constants.h"

@protocol CBImageViewProtocol <NSObject>
@optional
- (void)cbImageView:(UIImageView *)cbImageView didFinishUpdatingImageFromUrl:(NSString *)url;
- (void)cbImageView:(UIImageView *)cbImageView didFinishDownloadingImage:(UIImage *)aDownloadedImage;
- (void)cbImageView:(UIImageView *)cbImageView didFinishDownloadingImage:(UIImage *)aDownloadedImage downloadFailUrl:(NSString *)url;
- (void)cbImageView:(UIImageView *)cbImageView downloadFailUrl:(NSString *)url;
@end

@interface UIImageView (Custom) <DownloadProtocol>

//@property (nonatomic, strong) NSNumber      *processImgType;
@property (nonatomic, assign) id<CBImageViewProtocol>            categoryDelegate;
- (void)loadImageForUrl:(NSString *)url;
- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type;
- (void)loadImageForUrl:(NSString *)url defaultImage:(UIImage *)defaultImage;
- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type defaultImage:(UIImage *)defaultImage;
- (void)cancel;
- (void)quit;
//not used
/*
 - (void)loadProfileImageForUrl:(NSString *)url;
 - (void)loadProfileImageForUrl:(NSString *)url processImage:(PROCESSIMAGE)processImageType;
 */
@end
