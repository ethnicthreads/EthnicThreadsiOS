//
//  ChangePasswordViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@protocol ChangePasswordViewDelegate <NSObject>
- (void)closeChangePasswordView;
- (void)changePasswordSuccess:(NSString *)currentPassword;
@end

@interface ChangePasswordViewController : BaseViewController
@property (nonatomic, assign) id <ChangePasswordViewDelegate> delegate;
@end
