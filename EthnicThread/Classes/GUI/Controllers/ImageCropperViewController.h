//
//  ImageCropperViewController.h
//  EthnicThread
//
//  Created by PhuocDuy on 5/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@class ImageCropperViewController;

@protocol ImageCropperDelegate <NSObject>
- (void)imageCropper:(ImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(ImageCropperViewController *)cropperViewController;
@end

@interface ImageCropperViewController : BaseViewController

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) id<ImageCropperDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end