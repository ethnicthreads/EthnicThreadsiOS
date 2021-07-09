//
//  UIActionSheet+Custom.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/27/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "UIActionSheet+Custom.h"
#import <objc/runtime.h>

@implementation UIActionSheet (Custom)
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
