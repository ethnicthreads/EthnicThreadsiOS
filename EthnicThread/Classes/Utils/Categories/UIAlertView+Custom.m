//
//  UIAlertView+Custom.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/25/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UIAlertView+Custom.h"
#import <objc/runtime.h>

@implementation UIAlertView (Custom)
@dynamic context;

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)context {
    return objc_getAssociatedObject(self, @selector(context));
}

- (void)dealloc {
    self.context = nil;
}
@end
