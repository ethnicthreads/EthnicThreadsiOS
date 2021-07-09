//
//  ImagePopupView.m
//  EthnicThread
//
//  Created by Nguyen Loc on 10/17/15.
//  Copyright © 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "NewImagePopupView.h"
#import "UIImageView+Custom.h"
#import "CustomImageView.h"

@interface NewImagePopupView() <UIScrollViewDelegate, CBImageViewProtocol>
@property (nonatomic, assign) IBOutlet CustomImageView      *zoomImageView;
@property (nonatomic, assign) IBOutlet UIScrollView         *scrollView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *aiProgress;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidthZoomView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightZoomView;

@property (nonatomic) CGFloat                       zoomScale;
@end

@implementation NewImagePopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initGUI {
    [super initGUI];
    self.zoomImageView.categoryDelegate = self;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 3.0f;
    self.zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.lcWidthZoomView.constant = [UIScreen mainScreen].bounds.size.width;
    self.lcHeightZoomView.constant = [UIScreen mainScreen].bounds.size.height;
}

- (void)startLoadImage {
    if (self.loaded == NO) {
        self.loaded = YES;
        [self.aiProgress startAnimating];
        if ([self.imageObj isKindOfClass:[NSString class]]) {
            [self.zoomImageView loadImageForUrl:self.imageObj type:IMAGE_DONOTHING];
        }
        else if ([self.imageObj isKindOfClass:[UIImage class]]) {
            [self.zoomImageView setImage:self.imageObj];
            [self.aiProgress stopAnimating];
        }
    }
}

- (BOOL)shouldHideNavigationBar {
    return YES;
}

- (BOOL)shouldHideStatusBar {
    return YES;
}

- (void)setImageUrl:(NSString *)url {
    self.imageObj = url;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.zoomImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.zoomScale = scale;
}

#pragma mark - CBImageViewProtocol
- (void)cbImageView:(UIImageView *)cbImageView didFinishDownloadingImage:(UIImage *)aDownloadedImage downloadFailUrl:(NSString *)url {
    [self.aiProgress stopAnimating];
    [self.aiProgress setHidden:YES];
}

- (void)cbImageView:(UIImageView *)cbImageView downloadFailUrl:(NSString *)url {
    [self.aiProgress stopAnimating];
    [self.aiProgress setHidden:YES];
}

@end
