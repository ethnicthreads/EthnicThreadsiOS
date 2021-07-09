//
//  MoreInfoViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/11/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

#define USERINFO_ACTION_KEY     @"userinfo_action_key"
#define USERINFO_ITEM_KEY       @"userinfo_item_key"

@interface MoreInfoViewController : BaseViewController
@property (nonatomic, strong) UIImage         *avatarImage;
@property (nonatomic, strong) UIImage         *firstImage;
@property (nonatomic, strong) ItemModel       *itemModel;
@property (nonatomic, assign) BOOL            shouldAutoLoadComments;

- (void)sendActionToServerIfNeed:(NSDictionary *)notifUserInfo;
@end
