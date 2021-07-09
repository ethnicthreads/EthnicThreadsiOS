//
//  LikersView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/28/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "LikersView.h"
#import "UserModel.h"
#import "Constants.h"
#import "Utils.h"

@interface LikersView()
@property (nonatomic, strong) UIFont    *mainFont;
@property (nonatomic, strong) NSString  *rear;
@end

@implementation LikersView

- (void)initGUI {
    [super initGUI];
    self.mainFont = [UIFont systemFontOfSize:MINI_FONT_SIZE];
    self.rear = NSLocalizedString(@"_all", @"");
}

- (void)setItemModel:(ItemModel *)itemModel {
    _itemModel = itemModel;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger count = 0;
    CGFloat totalWidth = 0;
    CGFloat rearWidth = [Utils calculateWidthForString:self.rear withHeight:self.frame.size.height andFont:self.mainFont] + 2;
    totalWidth += rearWidth;
    UIView *leadingView = self;
    for (int i = 0; i < self.itemModel.latest_likers.count; i++) {
        SellerModel *liker = [self.itemModel.latest_likers objectAtIndex:i];
        NSString *title = [NSString stringWithFormat:@"%@,", [liker getDisplayName]];
        if (i == self.itemModel.total_likes - 1) {
            title = [NSString stringWithFormat:@"%@", [liker getDisplayName]];
        }
        CGFloat width = [Utils calculateWidthForString:title
                                            withHeight:self.frame.size.height
                                               andFont:self.mainFont] + 2;
        totalWidth += width;
        if (totalWidth >= self.frame.size.width) {
            break;
        }
        
        UIButton *button = [[UIButton alloc] init];
        [button.titleLabel setFont:self.mainFont];
        [button setTitleColor:LIGHT_BLACK_COLOR_TEXT forState:UIControlStateNormal];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = i + 1;
        [button addTarget:self action:@selector(handleLikerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        NSLayoutConstraint *lc;
        if (leadingView == self) {
            lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leadingView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        }
        else {
            lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leadingView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        }
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
        [button addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.frame.size.height];
        [button addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [self addConstraint:lc];
        
        leadingView = button;
        count++;
    }
    
    if (count < self.itemModel.total_likes) {
        UIButton *button = [[UIButton alloc] init];
        [button.titleLabel setFont:self.mainFont];
        [button setTitleColor:LIGHT_BLACK_COLOR_TEXT forState:UIControlStateNormal];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:self.rear forState:UIControlStateNormal];
        button.tag = 0;
        [button addTarget:self action:@selector(handleLikerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        NSLayoutConstraint *lc;
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:rearWidth];
        [button addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.frame.size.height];
        [button addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [self addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leadingView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [self addConstraint:lc];
    }
}

- (void)handleLikerButton:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        if ([self.delegate respondsToSelector:@selector(openLikersPage:)]) {
            [self.delegate openLikersPage:self.itemModel];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(openSellerProfilePage:)]) {
            SellerModel *user = [self.itemModel.latest_likers objectAtIndex:button.tag - 1];
            [self.delegate openSellerProfilePage:user];
        }
    }
}
@end
