//
//  EthnicPopup.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "EthnicPopup.h"
#import "Constants.h"

#define kCODialogPopScale 0.5

@interface CBAlertOverlayWindow : UIWindow
@property (nonatomic, strong) EthnicPopup *dialog;
@property (nonatomic, assign) BOOL        shown;
@end

@interface EthnicPopup()
@property (nonatomic, strong) CBAlertOverlayWindow      *overlayWindow;
@property (nonatomic, assign) id<EthnicPopupDelegate>   delegate;

@property (nonatomic, assign) IBOutlet UILabel          *lblTitle;
@property (nonatomic, assign) IBOutlet UIView           *containerView;
@property (nonatomic, assign) IBOutlet UIButton         *btnClose;
@property (nonatomic, assign) id <ContentViewProtocol>  contentViewProtocol;

- (IBAction)handleCloseButton:(id)sender;
@end

@implementation EthnicPopup

- (id)initWithTitle:(NSString *)title andDelegate:(id<EthnicPopupDelegate>)delegate {
    UINib *nib = [UINib nibWithNibName:@"EthnicPopup" bundle:nil];
    self = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.lblTitle.text = title;
    }
    return self;
}

- (void)showWithView:(UIView *)view {
    //get UIWindow
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    CBAlertOverlayWindow *overlay = [CBAlertOverlayWindow new];
    overlay.opaque = NO;
    overlay.windowLevel = UIWindowLevelStatusBar + 1;
    overlay.frame = window.bounds;
    overlay.alpha = 0.0;
    overlay.dialog = self;
    
    // Layout components
    if ([view conformsToProtocol:@protocol(ContentViewProtocol)]) {
        self.contentViewProtocol = (id <ContentViewProtocol>)view;
    }
    CGRect rect = view.frame;
    rect.origin.y = 0;
    view.frame = rect;
    [self.containerView addSubview:view];
    
    // Scale down ourselves for pop animation
    self.transform = CGAffineTransformMakeScale(kCODialogPopScale, kCODialogPopScale);
    
    [overlay addSubview:self];
    [overlay makeKeyAndVisible];
    
    self.overlayWindow = overlay;
    // Animate
    self.transform = CGAffineTransformIdentity;
    overlay.alpha = 1.0;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)close {
    self.overlayWindow.shown = NO;
    [self.overlayWindow setNeedsDisplay];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.contentViewProtocol cancelAllThreadsBeforeQuid];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClosePopup:)]) {
            [self.delegate didClosePopup:self];
        }
        [self removeFromSuperview];
        self.overlayWindow.dialog = nil;
        
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        [window makeKeyAndVisible];
        [window.rootViewController preferredStatusBarStyle];
        [window.rootViewController setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    });
}

- (IBAction)handleCloseButton:(id)sender {
    [self close];
}

- (void)clearDimmedBackgroundInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
}

- (void)drawDimmedBackgroundInRect:(CGRect)rect {
    // General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor *greyInner = [UIColor colorWithWhite:0.0 alpha:0.70];
    UIColor *greyOuter = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    // Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)greyOuter.CGColor,
                               (id)greyInner.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    // Rectangle Drawing
    CGPoint mid = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawRadialGradient(context,
                                gradient,
                                mid, 10,
                                mid, CGRectGetMidY(rect),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    // Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
@end


@implementation CBAlertOverlayWindow

- (id)init {
    if (self = [super init]) {
        _shown = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _shown = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_shown) [self.dialog drawDimmedBackgroundInRect:rect];
    else [self.dialog clearDimmedBackgroundInRect:rect];
}

@end
