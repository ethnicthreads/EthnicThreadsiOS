//
//  LoginWithEmailView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "AccountProtocol.h"
#import "UserAuthortyDelegate.h"

@interface LoginWithEmailView : BaseView <AccountProtocol>

@property (nonatomic, weak) id <UserAuthortyDelegate> delegate;
@property (nonatomic, strong) UILabel                 *lblTitle;
@end
