//
//  ListedItemsViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemsViewController.h"

@interface ListedItemsViewController : ItemsViewController
@property (nonatomic, strong) UserModel         *userModel;
@property (nonatomic, assign) BOOL              canBackToMainMenu;
@property (nonatomic, assign) BOOL              allowEditing;
@end
