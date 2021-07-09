//
//  UIButton+Custom.h
//  EthnicThread
//
//  Created by Nam Phan on 12/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "DownloadProtocol.h"
#import "Constants.h"

@interface UIButton (Custom) <DownloadProtocol>
- (void)loadImageForUrl:(NSString *)url;
- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type;
- (void)loadImageForUrl:(NSString *)url defaultImage:(UIImage *)defaultImage;
- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type defaultImage:(UIImage *)defaultImage;
- (void)cancel;
- (void)quit;
@end
