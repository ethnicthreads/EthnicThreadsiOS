//
//  UsersViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "FollowerTableViewCell.h"
#import "SellerProfileViewController.h"

#define USER_PER_COUNT                   30

@interface UsersViewController : BaseViewController <SlideNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) IBOutlet UITableView      *tableView;
@property (nonatomic, strong) NSMutableArray            *users;
@property (nonatomic, assign) NSInteger                 downLoadingPage;
@end
