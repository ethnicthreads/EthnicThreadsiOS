//
//  StarRatingView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StarRatingView.h"
#import "Constants.h"

#define kStartHeight 18.0f

@interface StarRatingView()
@property (nonatomic) CGRect                starRect;
@property (nonatomic, strong) CALayer       *tintLayer;
@property (nonatomic, strong) CALayer       *starBackground;
@property (nonatomic, strong) CALayer       *starMask;
@end

@implementation StarRatingView
@synthesize tintLayer;

- (void)initGUI {
    [super initGUI];
    self.opaque = NO;
    self.allowRating = NO;
    CGFloat width = kStartHeight * 5 + 25;
    self.starRect = CGRectMake((self.frame.size.width - width) / 2, 0, width, kStartHeight);
    
    self.starBackground = [CALayer layer];
    self.starBackground.contents = (__bridge id)([UIImage imageNamed:@"5starsgray"].CGImage);
    self.starBackground.frame = self.starRect;
    [self.layer addSublayer:self.starBackground];
    
    tintLayer = [CALayer layer];
    tintLayer.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
    [tintLayer setBackgroundColor:[UIColor yellowColor].CGColor];
    
    [self.layer addSublayer:tintLayer];
    self.starMask = [CALayer layer];
    self.starMask.contents = (__bridge id)([UIImage imageNamed:@"5starsgray"].CGImage);
    self.starMask.frame = self.starRect;
    [self.layer addSublayer:self.starMask];
    tintLayer.mask = self.starMask;

    [self performSelector:@selector(ratingDidChange) withObject:nil afterDelay:0.1];
}

- (void)layoutComponents {
    CGRect rect = self.starRect;
    rect.origin.x = (self.frame.size.width - self.starRect.size.width) / 2;
    rect.origin.y = (self.frame.size.height - self.starRect.size.height) / 2;
    self.starRect = rect;
    self.starMask.frame = self.starRect;
    self.starBackground.frame = self.starRect;
    [super layoutComponents];
}

- (void)setRating:(NSInteger)rating {
    _rating = rating;
    [self ratingDidChange];
}

- (void)setAllowRating:(BOOL)allowRating {
    _allowRating = allowRating;
    self.userInteractionEnabled = allowRating;
}

- (void)ratingDidChange {
    [self.tintLayer setBackgroundColor:[UIColor yellowColor].CGColor];
    float barWitdhPercentage = (_rating / 100.0f) * self.starRect.size.width + self.starRect.origin.x;
    self.tintLayer.frame = CGRectMake(0, 0, barWitdhPercentage, self.frame.size.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, [[[touches allObjects] lastObject] locationInView:self])) {
        float xpos = [[[touches allObjects] lastObject] locationInView:self].x - self.starRect.origin.x;
        int star = MIN(4, xpos / (self.starRect.size.width / 5.0f));
        self.rating = (star + 1) * 20.0f;
        [self ratingDidChange];
    }
}
@end