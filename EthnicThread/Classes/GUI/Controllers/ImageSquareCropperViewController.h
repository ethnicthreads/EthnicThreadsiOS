//
//  ImageCropperViewController.h
//  Circles-io
//
//  Created by PhuocDuy on 5/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@class ImageSquareCropperViewController;

@protocol ImageCropperDelegate <NSObject>
- (void)imageCropper:(ImageSquareCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(ImageSquareCropperViewController *)cropperViewController;
@end

@interface ImageSquareCropperViewController : BaseViewController

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) id<ImageCropperDelegate> delegate;
@property (nonatomic, assign) CGRect    cropFrame;
@property (nonatomic, assign) BOOL      isRoundCroped;
@property (nonatomic, strong) id        context;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end