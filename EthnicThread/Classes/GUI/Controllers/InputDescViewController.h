//
//  InputDescViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/17/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@protocol InputDescViewControllerDelegate <NSObject>
- (void)inputComplete:(NSString *)text;
@end

@interface InputDescViewController : BaseViewController
@property (nonatomic, strong) NSString                              *pageTitle;
@property (nonatomic, strong) NSString                              *content;
@property (nonatomic, assign) id <InputDescViewControllerDelegate>  delegate;
@end
