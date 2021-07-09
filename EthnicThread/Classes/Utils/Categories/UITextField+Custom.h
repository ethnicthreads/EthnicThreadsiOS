//
//  UITextField+Custom.h
//  EthnicThread
//
//  Created by PhuocDuy on 3/30/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Custom)
- (void)addTopRightButtonOfKeyBoard:(NSString *)title textColor:(UIColor *)color target:(id)target action:(SEL)action;
@end
