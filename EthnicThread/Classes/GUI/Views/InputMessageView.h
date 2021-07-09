//
//  InputMessageView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/21/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "ETPlaceHolderTextView.h"

@interface InputMessageView : BaseView
@property (nonatomic, strong) NSLayoutConstraint    *lcHeight;
@property (nonatomic, strong) ETPlaceHolderTextView *textView;
@property (nonatomic, strong) UIButton              *btnSend;
- (void)resetTextView;
@end
