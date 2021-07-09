//
//  FollowersViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UsersViewController.h"
#import "UserModel.h"

@interface FollowersViewController : UsersViewController
@property (nonatomic, strong) UserModel         *userModel;
@property (nonatomic, assign) BOOL              canBackToMainMenu;
@end
