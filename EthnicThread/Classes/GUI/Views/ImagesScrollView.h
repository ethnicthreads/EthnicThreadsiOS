//
//  ImagesScrollView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/10/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagesScrollViewDelegate <NSObject>
- (void)popupZoomingImages:(NSArray *)images currentIndex:(NSInteger)index; // UIImage or NSString (url)
@optional
- (void)removedImageAtIndex:(NSInteger)index;
@end

@interface ImagesScrollView : UIScrollView
@property (nonatomic, assign) BOOL      allowRemove;
@property (nonatomic, assign) id <ImagesScrollViewDelegate> aDelegate;
- (UIImage *)getFirstImage;
- (void)setImages:(NSMutableArray *)images andSize:(CGSize)size;//image: UIImage or NSString (url)
- (void)displayFirstImage:(UIImage *)firstImage;
- (void)displayFirstImageUrl:(NSString *)firstImageUrl;
- (void)addImage:(UIImage *)image animate:(BOOL)animated;
- (void)removeViewingImageWithAnimate:(BOOL)animated;
@end
