//
//  ImagePopupViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ImagePopupViewController.h"
#import "UIImageView+Custom.h"
#import "AnImagePopupView.h"
#import "NewImagePopupView.h"

@interface ImagePopupViewController () <UIScrollViewDelegate> {
    BOOL shouldScrolling;
}
@property (nonatomic, assign) IBOutlet UIButton             *btnClose;
@property (nonatomic, assign) IBOutlet UIScrollView         *scrollView;
@property (nonatomic, assign) IBOutlet UILabel              *lblPage;
@property (nonatomic, strong) UIView                        *contentView;
@property (nonatomic, strong) NSMutableArray                *imagePopups;
@end

@implementation ImagePopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initVariables {
    [super initVariables];
    shouldScrolling = YES;
}

- (void)initComponentUI {
    [super initComponentUI];
    self.btnClose.layer.cornerRadius = 3;
    self.btnClose.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnClose.layer.borderWidth = 1;
    
    self.contentView = [[UIView alloc] init];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView addSubview:self.contentView];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.scrollView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.height];
    [self.contentView addConstraint:lc];
    
    
    self.imagePopups = [[NSMutableArray alloc] init];
    UIView *prevView = nil;
    
    for (int i = 0; i < self.images.count; i++) {
        id image = [self.images objectAtIndex:i];
//        AnImagePopupView *imageZoomView = [[[UINib nibWithNibName:NSStringFromClass([AnImagePopupView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        NewImagePopupView *imageZoomView = [[[UINib nibWithNibName:NSStringFromClass([NewImagePopupView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        imageZoomView.imageObj = image;
        [self.contentView addSubview:imageZoomView];
        [imageZoomView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *lc;
        if (i == 0) {
            lc = [NSLayoutConstraint constraintWithItem:imageZoomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        }
        else {
            lc = [NSLayoutConstraint constraintWithItem:imageZoomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:prevView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
        }
        [self.contentView addConstraint:lc];
        if (i == self.images.count - 1) {
            lc = [NSLayoutConstraint constraintWithItem:imageZoomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
            [self.contentView addConstraint:lc];
        }
        lc = [NSLayoutConstraint constraintWithItem:imageZoomView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.width];
        [imageZoomView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageZoomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [self.contentView addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:imageZoomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.contentView addConstraint:lc];
        
        
        if (i == self.currentIndex) {
            [imageZoomView startLoadImage];
        }
        [self.imagePopups addObject:imageZoomView];
        prevView = imageZoomView;
    }
    
    [self updatePageLabel];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.scrollView.contentSize.width > 0 && shouldScrolling) {
        shouldScrolling = NO;
        CGRect rect = self.scrollView.frame;
        rect.origin.x = self.scrollView.frame.size.width * self.currentIndex;
        [self.scrollView scrollRectToVisible:rect animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldHideNavigationBar {
    return YES;
}

- (BOOL)shouldHideStatusBar {
    return YES;
}

- (IBAction)handleCloseButton:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)updatePageLabel {
    self.lblPage.text = [NSString stringWithFormat:@"%d/%lu", self.currentIndex + 1, (unsigned long)self.images.count];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    int index = (int)offsetX / scrollView.frame.size.width;
    if (index != self.currentIndex) {
        self.currentIndex = index;
        [self updatePageLabel];
        if (index >= 0 && index < self.images.count) {
            AnImagePopupView *imagePopup = [self.imagePopups objectAtIndex:index];
            [imagePopup startLoadImage];
        }
    }
}
@end
