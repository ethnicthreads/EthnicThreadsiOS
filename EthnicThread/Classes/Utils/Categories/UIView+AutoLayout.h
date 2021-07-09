//
//  UIView+AutoLayout.h
//  Saleshood
//
//  Created by Nam Phan on 8/26/15.
//  Copyright (c) 2015 Codebox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)
- (void)constraintMatchingBoundsWithItem:(UIView *)item2;
- (NSLayoutConstraint *)addHeightConstraint:(CGFloat)height;
- (NSLayoutConstraint *)addHeightEqualOrGreaterConstraint:(CGFloat)height;
- (NSLayoutConstraint *)addHeightConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier;
- (NSLayoutConstraint *)addHeightConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier constant:(CGFloat)height;
- (NSLayoutConstraint *)addWidthConstraint:(CGFloat)width;
- (NSLayoutConstraint *)addWidthEqualOrGreaterConstraint:(CGFloat)width;
- (NSLayoutConstraint *)addWidthConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier;
- (NSLayoutConstraint *)addWidthConstraintForItem:(UIView *)forItem withMultiplier:(CGFloat)mulitiplier constant:(CGFloat)width;
- (void)addFitContraintsForItem:(UIView *)forItem;
- (void)addFitContraintsForItem:(UIView *)forItem margin:(CGFloat)margin;
- (void)addLeadingConstraintForItem:(UIView *)forItem;
- (void)addLeadingConstraintForItem:(UIView *)forItem leading:(CGFloat)leading;
- (NSLayoutConstraint *)addLeadingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem;
- (NSLayoutConstraint *)addLeadingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem leading:(CGFloat)leading;
- (NSLayoutConstraint *)addLeadingConstraintForItem:(UIView *)forItem rightItem:(UIView *)rightItem leading:(CGFloat)leading;
- (void)addTrailingConstraintForItem:(UIView *)forItem;
- (void)addTrailingConstraintForItem:(UIView *)forItem trailing:(CGFloat)trailing;
- (void)addTrailingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem;
- (void)addTrailingConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem trailing:(CGFloat)trailing;
- (void)addTrailingConstraintForItem:(UIView *)forItem leftItem:(UIView *)leftItem trailing:(CGFloat)trailing;
- (NSLayoutConstraint *)addSelfTrailingConstraintToItem:(UIView *)toItem trailing:(CGFloat)trailing;
- (void)addTopConstraintForItem:(UIView *)forItem;
- (void)addTopConstraintForItem:(UIView *)forItem top:(CGFloat)top;
- (void)addTopConstraintForItem:(UIView *)forItem bottomItem:(UIView *)bottomItem top:(CGFloat)top;
- (void)addTopConstraintForItem:(UIView *)forItem equalTopItem:(UIView *)topItem top:(CGFloat)top;
- (void)setBottomConstraintBaseOnItem:(UIView *)baseItem;
- (void)setBottomConstraintBaseOnItem:(UIView *)baseItem margin:(CGFloat)margin;
- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem;
- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem bottom:(CGFloat)bottom;
- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem aboveItem:(UIView *)aboveItem bottom:(CGFloat)bottom;
- (NSLayoutConstraint *)addBottomConstraintForItem:(UIView *)forItem equalBottomItem:(UIView *)bottomItem bottom:(CGFloat)bottom;
- (NSLayoutConstraint *)addSelfBottomConstraintToItem:(UIView *)forItem bottom:(CGFloat)bottom;
- (NSLayoutConstraint *)selfBottomConstraint;
- (void)addCenterConstraintForItem:(UIView *)forItem;
- (void)addCenterConstraintForItem:(UIView *)forItem center:(CGFloat)center;
- (void)addCenterXConstraintForItem:(UIView *)forItem;
- (void)addCenterXConstraintForItem:(UIView *)forItem centerX:(CGFloat)centerX;
- (void)addCenterXConstraintForItem:(UIView *)forItem toItem:(UIView *)toItem;
- (void)addCenterYConstraintForItem:(UIView *)forItem;
- (void)addCenterYConstraintForItem:(UIView *)forItem centerY:(CGFloat)centerY;
- (NSLayoutConstraint *)widthConstraint;
- (NSLayoutConstraint *)heightConstraint;
@end
