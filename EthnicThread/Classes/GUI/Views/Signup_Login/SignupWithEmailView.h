//
//  SignupWithEmailView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AccountProtocol.h"
#import "UserAuthortyDelegate.h"
#import "BaseView.h"

@interface SignupWithEmailView : BaseView <AccountProtocol>

@property (nonatomic, weak) id <UserAuthortyDelegate> delegate;
@end
