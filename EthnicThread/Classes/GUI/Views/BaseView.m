//
//  BaseView.m
//  EthnicThread
//
//  Created by Nam Phan on 12/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVariables];
        [self initGUI];
        [self layoutComponents];
        [self didLoadGUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initVariables];
    [self initGUI];
    [self layoutComponents];
    [self didLoadGUI];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    viewHeight = CGRectGetHeight(frame);
}

- (void)dealloc {
    self.asyncThread = nil;
}

- (void)initVariables {
    viewHeight = CGRectGetHeight(self.frame);
}

- (void)initGUI {
    self.autoresizesSubviews = NO;
}

- (void)layoutComponents {
}

- (void)didLoadGUI {
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutComponents];
}

- (void)stopAllThreads {
    @try {
        [[OperationManager shareInstance] cancelAllThreadsInTarget:self];
        [self.asyncThread cancel];
        self.asyncThread = nil;
        if ([self conformsToProtocol:@protocol(DownloadProtocol)]) {
            [[DownloadManager shareInstance] removeListener:(id<DownloadProtocol>)self];
        }
        NSArray *subviews = [self subviews];
        for (UIView *view in subviews) {
            [self retrieveAllSubviewsToStop:view];
        }
        [[EventManager shareInstance] removeListenerInAllChannels:self];
    }
    @catch (NSException *exception) {
        DLog(@"exception = %@", exception);
    }
}

- (void)retrieveAllSubviewsToStop:(UIView *)aViewNode {
    if ([aViewNode isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)aViewNode quit];
    }
    else if ([aViewNode isKindOfClass:[UIButton class]]) {
        [(UIButton *)aViewNode quit];
    }
    else if ([aViewNode isKindOfClass:[BaseView class]]) {
        [(BaseView *)aViewNode stopAllThreads];
    }
    NSArray *subviews = [aViewNode subviews];
    for (UIView *view in subviews) {
        [self retrieveAllSubviewsToStop:view];
    }
}

- (CGFloat)getHeightOfView {
    return viewHeight;
}

- (void)updateContraintAndRenderScreenIfNeeded {
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
@end
