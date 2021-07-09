//
//  EthnicPopup.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EthnicPopupDelegate <NSObject>
@optional
- (void)didClosePopup:(id)view;
@end

@protocol ContentViewProtocol <NSObject>
- (void)cancelAllThreadsBeforeQuid;
@end

@interface EthnicPopup : UIView

- (id)initWithTitle:(NSString *)title andDelegate:(id<EthnicPopupDelegate>)delegate;
- (void)showWithView:(UIView *)view;
- (void)close;
@end
