//
//  ETPlaceHolderTextView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;
@end
