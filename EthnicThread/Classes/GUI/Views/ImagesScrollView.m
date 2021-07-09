//
//  ImagesScrollView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/10/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "ImagesScrollView.h"
#import "CustomImageView.h"
#import "Constants.h"
#import "UIImageView+Custom.h"
#import "DownloadManager.h"

@interface GalleryImageView : CustomImageView
@property (nonatomic, strong) UIButton *btnRemove;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *lbLoading;
@end

@implementation GalleryImageView

- (id)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)addRemoveButton {
    self.btnRemove = [[UIButton alloc] init];
    [self.btnRemove setBackgroundColor:[UIColor clearColor]];
    [self.btnRemove setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.btnRemove setImage:[UIImage imageNamed:@"delete_button.png"] forState:UIControlStateNormal];
    [self.btnRemove setHidden:YES];
    [self addSubview:self.btnRemove];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.btnRemove attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35];
    [self.btnRemove addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.btnRemove attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35];
    [self.btnRemove addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.btnRemove attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:2];
    [self addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.btnRemove attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:2];
    [self addConstraint:lc];
}

- (void)visibleIndicatorAnimation {
    if (self.indicator == nil) {
        self.indicator = [[UIActivityIndicatorView alloc] init];
        [self.indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:self.indicator];
        NSLayoutConstraint *lc;
        lc = [NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.indicator addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self.indicator addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.indicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-10];
        [self addConstraint:lc];
        
        self.lbLoading = [[UILabel alloc] init];
        [self.lbLoading setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.lbLoading.text = NSLocalizedString(@"spinner_text_loading", @"");
        self.lbLoading.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
        self.lbLoading.textColor = [UIColor lightGrayColor];
        self.lbLoading.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbLoading];
        lc = [NSLayoutConstraint constraintWithItem:self.lbLoading attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120];
        [self.lbLoading addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.lbLoading attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:21];
        [self.lbLoading addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.lbLoading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.lbLoading attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.indicator attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5];
        [self addConstraint:lc];
    }
    [self.indicator startAnimating];
}

- (void)setImage:(UIImage *)image {
    self.contentMode = UIViewContentModeScaleAspectFit;
    [self setBackgroundColor:GRAY_COLOR];
    [super setImage:image];
    [self.btnRemove setHidden:image == nil];
    if (image) {
        [self.indicator removeFromSuperview];
        self.indicator = nil;
        [self.lbLoading removeFromSuperview];
        self.lbLoading = nil;
    }
}
@end

@interface ImagesScrollView() <UIScrollViewDelegate> {
    int currentPage;
}
@property (nonatomic, strong) NSLayoutConstraint          *lcHeightContentView;
@property (nonatomic, strong) NSLayoutConstraint          *lcWidthContentView;
@property (nonatomic, strong) UIView                      *contentView;
@property (nonatomic, strong) NSMutableArray              *images;
@property (nonatomic, strong) NSMutableArray              *imageViews;
@property (nonatomic, assign) CGSize                      size;
@property (nonatomic, strong) UIButton                    *btnPrev;
@property (nonatomic, strong) UIButton                    *btnNext;
@end

@implementation ImagesScrollView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    [self setBackgroundColor:[UIColor clearColor]];
    self.images = [[NSMutableArray alloc] init];
    self.imageViews = [[NSMutableArray alloc] init];
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)loadImageAtIndex:(NSInteger)index {
    if (index < self.imageViews.count && index < self.images.count) {
        GalleryImageView *imageView = [self.imageViews objectAtIndex:index];
        [imageView visibleIndicatorAnimation];
        id obj = [self.images objectAtIndex:index];
        if ([obj isKindOfClass:[UIImage class]]) {
            UIImage *image = obj;
            imageView.image = image;
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            [imageView loadImageForUrl:obj type:IMAGE_DONOTHING];
        }
    }
}

- (UIImage *)getFirstImage {
    if (self.imageViews.count == 0) return nil;
    GalleryImageView *imageView = [self.imageViews objectAtIndex:0];
    return imageView.image;
}

- (void)setImages:(NSMutableArray *)images andSize:(CGSize)size {
    if (images) self.images = [NSMutableArray arrayWithArray:images];
    self.size = size;
    currentPage = 0;
    self.contentOffset = CGPointZero;
    
    if (!self.contentView) {
        self.contentView = [[UIView alloc] init];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.contentView];
        NSLayoutConstraint *lc;
        lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [self addConstraint:lc];
        self.lcHeightContentView = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.size.height];
        [self.contentView addConstraint:self.lcHeightContentView];
        
        GalleryImageView *imageView = [[GalleryImageView alloc] init];
        if (self.allowRemove) {
            [imageView addRemoveButton];
        }
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:imageView];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.size.width];
        [imageView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [self.contentView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.contentView addConstraint:lc];
    
        [self.imageViews addObject:imageView];
        
        self.lcWidthContentView = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(self.size.width * self.images.count)];
        [self.contentView addConstraint:self.lcWidthContentView];
        
        CGFloat buttonHeight = 50;
        self.btnPrev = [[UIButton alloc] init];
        [self.btnPrev addTarget:self action:@selector(handlePrevButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnPrev setBackgroundColor:[UIColor clearColor]];
        [self.btnPrev setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.btnPrev setImage:[UIImage imageNamed:@"gallery_prev_arrow"] forState:UIControlStateNormal];
        [self.superview addSubview:self.btnPrev];
        lc = [NSLayoutConstraint constraintWithItem:self.btnPrev attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonHeight];
        [self.btnPrev addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.btnPrev attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonHeight];
        [self.btnPrev addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.btnPrev attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:(self.lcHeightContentView.constant - buttonHeight) / 2];
        [self.superview addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.btnPrev attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-7];
        [self.superview addConstraint:lc];
        
        self.btnNext = [[UIButton alloc] init];
        [self.btnNext addTarget:self action:@selector(handleNextButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnNext setBackgroundColor:[UIColor clearColor]];
        [self.btnNext setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.btnNext setImage:[UIImage imageNamed:@"gallery_next_arrow"] forState:UIControlStateNormal];
        [self.superview addSubview:self.btnNext];
        lc = [NSLayoutConstraint constraintWithItem:self.btnNext attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonHeight];
        [self.btnNext addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.btnNext attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonHeight];
        [self.btnNext addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.btnNext attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:(self.lcHeightContentView.constant - buttonHeight) / 2];
        [self.superview addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.btnNext attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:7];
        [self.superview addConstraint:lc];
    }
    else {
        for (NSInteger i = self.imageViews.count - 1; i >= 0; i--) {
            if (i == 0) {
                UIImageView *imageView = [self.imageViews objectAtIndex:0];
                imageView.image = nil;
            }
            else {
                UIView *view = [self.imageViews objectAtIndex:i];
                [view removeFromSuperview];
                [self.imageViews removeObjectAtIndex:i];
            }
        }
        self.lcWidthContentView.constant = size.width * self.images.count;
    }
    
    GalleryImageView *imageView = [self.imageViews objectAtIndex:0];
    if (self.images.count > 0) {
        id obj = [self.images objectAtIndex:0];
        if ([obj isKindOfClass:[UIImage class]]) {
            UIImage *image = obj;
            imageView.image = image;
        }
        else {
            [imageView visibleIndicatorAnimation];
            [imageView loadImageForUrl:obj type:IMAGE_DONOTHING];
        }
    }
    
    [self.btnPrev setHidden:YES];
    [self.btnNext setHidden:self.images.count <= 1];
}

- (void)displayFirstImage:(UIImage *)firstImage {
    if (self.imageViews.count == 0 || firstImage == nil)
        return;
    GalleryImageView *imageView = [self.imageViews objectAtIndex:0];
    imageView.image = firstImage;
}

- (void)displayFirstImageUrl:(NSString *)firstImageUrl {
    if (self.imageViews.count == 0 || firstImageUrl.length == 0)
        return;
    GalleryImageView *imageView = [self.imageViews objectAtIndex:0];
    [imageView loadImageForUrl:firstImageUrl type:IMAGE_DONOTHING];
}

- (void)addImage:(UIImage *)image animate:(BOOL)animated {
    if (!image) return;
    CGPoint offset = self.contentOffset;
    offset.x = self.size.width * (self.images.count - 1);
    self.contentOffset = offset;
    
    [self.images addObject:image];
    self.lcWidthContentView.constant = (self.size.width * self.images.count);
    
    if (self.images.count == 1) {
        [self loadImageAtIndex:0];
    }
    else {
        CGRect rect = CGRectMake(self.size.width * (self.images.count - 1), 0, self.size.width, self.size.height);
        GalleryImageView *imageView = [[GalleryImageView alloc] initWithFrame:rect];
        [imageView visibleIndicatorAnimation];
        if (self.allowRemove) {
            [imageView addRemoveButton];
        }
        imageView.image = image;
        [self.contentView addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        offset.x += self.size.width;
        if (animated) {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 self.contentOffset = offset;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        else {
            self.contentOffset = offset;
        }
    }
}

- (void)removeViewingImageWithAnimate:(BOOL)animated {
    if (currentPage >= self.images.count) return;
    
    if ([self.aDelegate respondsToSelector:@selector(removedImageAtIndex:)]) {
        [self.aDelegate removedImageAtIndex:currentPage];
    }
    
    CGFloat duration = 0;
    if (animated) duration = 0.25f;
    UIImageView *imageView = [self.imageViews objectAtIndex:currentPage];
    [imageView setImage:nil];
    NSInteger removedIndex = currentPage;
    
    if (removedIndex == self.images.count - 1) {
        // remove last image
        if (removedIndex > 0) {
            CGPoint offset = self.contentOffset;
            offset.x -= self.size.width;
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.contentOffset = offset;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    else {
        [UIView animateWithDuration:duration
                         animations:^{
                             for (NSInteger i = removedIndex + 1; i < self.imageViews.count; i++) {
                                 GalleryImageView *imv = [self.imageViews objectAtIndex:i];
                                 CGRect rect = imv.frame;
                                 rect.origin.x -= self.size.width;
                                 imv.frame = rect;
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    self.lcWidthContentView.constant = (self.size.width * (self.images.count - 1));
    [imageView removeFromSuperview];
    [self.imageViews removeObjectAtIndex:removedIndex];
    [self.images removeObjectAtIndex:removedIndex];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.allowRemove && currentPage < self.images.count && currentPage >= 0) {
        GalleryImageView *imageView = [self.imageViews objectAtIndex:currentPage];
        if (CGRectContainsPoint(imageView.btnRemove.frame, [[[touches allObjects] lastObject] locationInView:imageView])) {
            // remove image
            [self removeViewingImageWithAnimate:YES];
            return;
        }
    }
    
    // open image popup
    if ([self.aDelegate respondsToSelector:@selector(popupZoomingImages:currentIndex:)]) {
        [self.aDelegate popupZoomingImages:self.images currentIndex:currentPage];
    }
}

- (void)handlePrevButton:(id)sender {
    CGRect rect = self.frame;
    rect.origin.x = self.contentOffset.x - self.frame.size.width;
    [self scrollRectToVisible:rect animated:YES];
}

- (void)handleNextButton:(id)sender {
    CGRect rect = self.frame;
    rect.origin.x = self.contentOffset.x + self.frame.size.width;
    [self scrollRectToVisible:rect animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    int page = (int)offsetX / scrollView.frame.size.width;
    if (page != currentPage) {
        [self.btnPrev setHidden:(page == 0)];
        [self.btnNext setHidden:(page == self.images.count - 1)];
    }
    currentPage = page;
    if (page == self.imageViews.count && page < self.images.count) {
        GalleryImageView *imageView = [[GalleryImageView alloc] initWithFrame:CGRectMake(self.size.width * self.imageViews.count, 0, self.size.width, self.size.height)];
        [imageView visibleIndicatorAnimation];
        if (self.allowRemove) {
            [imageView addRemoveButton];
        }
        [self.contentView addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        [self loadImageAtIndex:self.imageViews.count - 1];
    }
}
@end
