//
//  MessageLabel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "MessageLabel.h"

@implementation MessageLabel

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 9, 0, 10))];
}

@end
