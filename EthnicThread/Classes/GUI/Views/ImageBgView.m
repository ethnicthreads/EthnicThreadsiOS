//
//  ImageBgView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/21/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ImageBgView.h"

@interface ImageBgView()

@property (nonatomic, strong) UIView            *overlayView;
@end

@implementation ImageBgView
- (void)initGUI {
    [super initGUI];
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    _bgImageView = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.bgImageView];
    
    _overlayView = [[UIView alloc] initWithFrame:rect];
    [self.overlayView setBackgroundColor:[UIColor blackColor]];
    [self.overlayView setAlpha:0.4];
    [self.overlayView setHidden:YES];
    [self addSubview:self.overlayView];
    
    [self sendSubviewToBack:self.overlayView];
    [self sendSubviewToBack:self.bgImageView];
}

- (void)layoutComponents {
    [super layoutComponents];
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    [self.bgImageView setFrame:rect];
    [self.overlayView setFrame:rect];
}

- (void)enableOverlayView {
    [self.overlayView setHidden:NO];
}
@end
