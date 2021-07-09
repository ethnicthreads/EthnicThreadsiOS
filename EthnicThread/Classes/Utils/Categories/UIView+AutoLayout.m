//
//  UIView+AutoLayout.m
//  Saleshood
//
//  Created by Nam Phan on 8/26/15.
//  Copyright (c) 2015 Codebox Solutions Ltd. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)
- (void)constraintMatchingBoundsWithItem:(UIView *)item2 {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [item2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [item2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [item2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:item2 attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [item2 addConstraint:constraint];
}

- (NSLayoutConstraint *)addHeightConstraint:(CGFloat)height {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:height];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addHeightEqualOrGreaterConstraint:(CGFloat)height {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:0 constant:height];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addHeightConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier {
    return [self addHeightConstraintForItem:forItem withMultiplier:mulitiplier constant:0];
}

- (NSLayoutConstraint *)addHeightConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier constant:(CGFloat)height {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:mulitiplier constant:height];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addWidthConstraint:(CGFloat)width {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:width];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addWidthEqualOrGreaterConstraint:(CGFloat)width {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:0 constant:width];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addWidthConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier {
    return [self addWidthConstraintForItem:forItem withMultiplier:mulitiplier constant:0];
}

- (NSLayoutConstraint *)addWidthConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier constant:(CGFloat)width {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:mulitiplier constant:width];
    [self addConstraint:lc];
    return lc;
}

- (void)addFitContraintsForItem:(UIView *)forItem {
    [self addLeadingConstraintForItem:forItem];
    [self addTrailingConstraintForItem:forItem];
    [self addTopConstraintForItem:forItem];
    [self addBottomConstraintForItem:forItem];
}

- (void)addFitContraintsForItem:(UIView *)forItem margin:(CGFloat)margin {
    [self addLeadingConstraintForItem:forItem leading:margin];
    [self addTrailingConstraintForItem:forItem trailing:-margin];
    [self addTopConstraintForItem:forItem top:margin];
    [self addBottomConstraintForItem:forItem bottom:-margin];
}

- (void)addLeadingConstraintForItem:(UIView *)forItem {
    [self addLeadingConstraintForItem:forItem leading:0];
}

- (void)addLeadingConstraintForItem:(UIView *)forItem leading:(CGFloat)leading {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:leading]];
}

- (NSLayoutConstraint *)addLeadingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem {
    return [self addLeadingConstraintForItem:forItem toItem:toItem leading:0];
}

- (NSLayoutConstraint *)addLeadingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem leading:(CGFloat)leading {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:toItem attribute:NSLayoutAttributeLeading multiplier:1 constant:leading];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addLeadingConstraintForItem:(UIView *)forItem rightItem:(UIView *)rightItem leading:(CGFloat)leading {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:rightItem attribute:NSLayoutAttributeTrailing multiplier:1 constant:leading];
    [self addConstraint:lc];
    return lc;
}

- (void)addTrailingConstraintForItem:(UIView *)forItem {
    [self addTrailingConstraintForItem:forItem trailing:0];
}

- (void)addTrailingConstraintForItem:(UIView *)forItem trailing:(CGFloat)trailing {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:trailing]];
}

- (void)addTrailingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem {
    [self addTrailingConstraintForItem:forItem toItem:toItem trailing:0];
}

- (void)addTrailingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem trailing:(CGFloat)trailing {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:toItem attribute:NSLayoutAttributeTrailing multiplier:1 constant:trailing]];
}

- (void)addTrailingConstraintForItem:(UIView *)forItem leftItem:(UIView *)leftItem trailing:(CGFloat)trailing {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:leftItem attribute:NSLayoutAttributeLeading multiplier:1 constant:trailing]];
}

- (NSLayoutConstraint *)addSelfTrailingConstraintToItem:(UIView *)toItem trailing:(CGFloat)trailing {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:toItem attribute:NSLayoutAttributeTrailing multiplier:1 constant:trailing];
    [self addConstraint:lc];
    return lc;
}

- (void)addTopConstraintForItem:(UIView *)forItem {
    [self addTopConstraintForItem:forItem top:0];
}

- (void)addTopConstraintForItem:(UIView *)forItem top:(CGFloat)top {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:top]];
}

- (void)addTopConstraintForItem:(UIView *)forItem bottomItem:(UIView *)bottomItem top:(CGFloat)top {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottomItem attribute:NSLayoutAttributeBottom multiplier:1 constant:top]];
}

- (void)addTopConstraintForItem:(UIView *)forItem equalTopItem:(UIView *)topItem top:(CGFloat)top {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topItem attribute:NSLayoutAttributeTop multiplier:1 constant:top]];
}

- (void)setBottomConstraintBaseOnItem:(UIView *)baseItem {
    [self setBottomConstraintBaseOnItem:baseItem margin:0];
}

- (void)setBottomConstraintBaseOnItem:(UIView *)baseItem margin:(CGFloat)margin {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:baseItem attribute:NSLayoutAttributeBottom multiplier:1 constant:margin]];
}

- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem {
    return [self addBottomConstraintForItem:forItem bottom:0];
}

- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem bottom:(CGFloat)bottom {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:bottom];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem aboveItem:(UIView *)aboveItem bottom:(CGFloat)bottom {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:aboveItem attribute:NSLayoutAttributeTop multiplier:1 constant:bottom];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem equalBottomItem:(UIView *)bottomItem bottom:(CGFloat)bottom {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomItem attribute:NSLayoutAttributeBottom multiplier:1 constant:bottom];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)addSelfBottomConstraintToItem:(UIView *)forItem bottom:(CGFloat)bottom {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:forItem attribute:NSLayoutAttributeBottom multiplier:1 constant:bottom];
    [self addConstraint:lc];
    return lc;
}

- (NSLayoutConstraint *)selfBottomConstraint {
    for (NSLayoutConstraint * constraint in self.constraints) {
        if ([NSStringFromClass([constraint class]) isEqualToString:@"NSLayoutConstraint"]) //to avoid private NSContentSizeLayoutConstraint iOS 9
            if (constraint.firstItem == self)
                if (constraint.firstAttribute == NSLayoutAttributeBottom)
                    return constraint;
    }
    return nil;
}


- (void)addCenterConstraintForItem:(UIView *)forItem {
    [self addCenterConstraintForItem:forItem center:0];
}

- (void)addCenterConstraintForItem:(UIView *)forItem center:(CGFloat)center {
    [self addCenterXConstraintForItem:forItem centerX:center];
    [self addCenterYConstraintForItem:forItem centerY:center];
}

- (void)addCenterXConstraintForItem:(UIView *)forItem {
    [self addCenterXConstraintForItem:forItem centerX:0];
}

- (void)addCenterXConstraintForItem:(UIView *)forItem centerX:(CGFloat)centerX {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:centerX]];
}

- (void)addCenterXConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:toItem attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void)addCenterYConstraintForItem:(UIView *)forItem {
    [self addCenterYConstraintForItem:forItem centerY:0];
}

- (void)addCenterYConstraintForItem:(UIView *)forItem centerY:(CGFloat)centerY {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:forItem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:centerY]];
}

- (NSLayoutConstraint *)widthConstraint {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([NSStringFromClass([constraint class]) isEqualToString:@"NSLayoutConstraint"]) //to avoid private NSContentSizeLayoutConstraint iOS 9
            if (constraint.firstItem == self)
                if (constraint.firstAttribute == NSLayoutAttributeWidth)
                    return constraint;
    }
    return nil;
}

- (NSLayoutConstraint *)heightConstraint {
    for (NSLayoutConstraint * constraint in self.constraints) {
        if ([NSStringFromClass([constraint class]) isEqualToString:@"NSLayoutConstraint"]) //to avoid private NSContentSizeLayoutConstraint iOS 9
            if (constraint.firstItem == self)
                if (constraint.firstAttribute == NSLayoutAttributeHeight)
                    return constraint;
    }
    return nil;
}
@end
