//
//  InputMessageView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/21/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "InputMessageView.h"

#define TEXTVIEW_MAX_LINE       3

@interface InputMessageView() <UITextViewDelegate> {
    CGFloat         heightDefault;
    CGFloat         delta;
}
@end

@implementation InputMessageView

- (void)initGUI {
    [super initGUI];
    
    NSLayoutConstraint *lc;
    self.btnSend = [[UIButton alloc] init];
    [self.btnSend setImage:[UIImage imageNamed:@"send_button.png"] forState:UIControlStateNormal];
    [self.btnSend setImage:[UIImage imageNamed:@"small_take_photo"] forState:UIControlStateHighlighted];
    self.btnSend.highlighted = YES;
    [self.btnSend setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.btnSend];
    lc = [NSLayoutConstraint constraintWithItem:self.btnSend attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35];
    [self.btnSend addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.btnSend attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35];
    [self.btnSend addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.btnSend attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.btnSend attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-5];
    [self addConstraint:lc];
    
    self.textView = [[ETPlaceHolderTextView alloc] init];
    [self.textView setFont:[UIFont systemFontOfSize:MEDIUM_FONT_SIZE]];
    self.textView.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
    self.textView.layer.borderWidth = 1;
    self.textView.delegate = self;
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.textView];
    lc = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.btnSend attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-8];
    [self addConstraint:lc];
}

- (void)setLcHeight:(NSLayoutConstraint *)lcHeight {
    _lcHeight = lcHeight;
    heightDefault = self.lcHeight.constant;
}

- (void)resetTextView {
    self.textView.text = @"";
    self.lcHeight.constant = heightDefault;
    self.btnSend.highlighted = YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.btnSend.highlighted = textView.text.length == 0;
    CGSize contentSize = textView.contentSize;
    if (contentSize.height > self.textView.frame.size.height) {
        if (delta == 0) {
            delta = contentSize.height - self.textView.frame.size.height;
        }
        if ((self.lcHeight.constant - (heightDefault - delta)) / delta < TEXTVIEW_MAX_LINE) {
            self.lcHeight.constant += delta;
        }
    }
    if (contentSize.height < self.textView.frame.size.height) {
        if ((self.lcHeight.constant - (heightDefault - delta)) / delta > 1) {
            self.lcHeight.constant -= delta;
        }
    }
}
@end
