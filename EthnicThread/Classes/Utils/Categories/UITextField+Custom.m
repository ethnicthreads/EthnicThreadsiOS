//
//  UITextField+Custom.m
//  EthnicThread
//
//  Created by PhuocDuy on 3/30/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "UITextField+Custom.h"

@implementation UITextField (Custom)
- (void)addTopRightButtonOfKeyBoard:(NSString *)title textColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title
                                                               style:UIBarButtonItemStyleBordered target:target
                                                              action:action];
    [button setTitleTextAttributes:@{NSForegroundColorAttributeName:color} forState:UIControlStateNormal];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace, button, nil]];
    self.inputAccessoryView = keyboardDoneButtonView;
}
@end
