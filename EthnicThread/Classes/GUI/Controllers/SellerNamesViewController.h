//
//  SellerNamesViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/24/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "BasicInfoUserModel.h"

@protocol SelerNamesViewControllerDelegate <NSObject>
- (void)searchSelerNameResult:(BasicInfoUserModel *)searchUser;
@end

@interface SellerNamesViewController : BaseViewController
@property (nonatomic, assign) id <SelerNamesViewControllerDelegate> delegate;
@end
