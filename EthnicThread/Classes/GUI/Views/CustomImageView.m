//
//  CustomImageView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/15/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CustomImageView.h"
#import "UIImageView+Custom.h"
#import "Categories.h"

@interface CustomImageView()
@property (nonatomic, strong) NSString      *url;
@property (nonatomic, strong) UIImage       *aImage;
@property (nonatomic, assign) PROCESSIMAGE  processType;
@end

@implementation CustomImageView

- (void)loadImageForUrl:(NSString *)url type:(PROCESSIMAGE)type defaultImage:(UIImage *)defaultImage {
    [super loadImageForUrl:url type:type defaultImage:defaultImage];
    self.url = url;
    self.aImage = defaultImage;
    self.processType = type;
}

- (void)setImage:(UIImage *)image {
    self.aImage = [image copy];
    [super setImage:image];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.url) {
        [super loadImageForUrl:self.url type:self.processType defaultImage:self.aImage];
    }
    else {
        [super setImage:self.aImage];
    }
//    DLog(@"%@", NSStringFromCGSize(self.frame.size));
}
@end
