//
//  IAmFollowingViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "IAmFollowingViewController.h"

@interface IAmFollowingViewController () <FollowerTableViewCellDelegate>

@end

@implementation IAmFollowingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"following", @"") andTextColor:BLACK_COLOR_TEXT];
}

- (Response *)connectToServer {
    return [CloudManager getIAmLollowing:[[[UserManager sharedInstance] getAccount] getIdString] andFromPage:self.downLoadingPage andPer:USER_PER_COUNT];
}

- (void)executeUpdateFollowThisSeller:(SellerModel *)seller threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager updateFollowASeller:[seller getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *dict = response.getJsonObject;
            [seller updateWithDictionary:dict];
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FOLLOWED_USER_NOTIFICATION object:nil userInfo:userInfo];
            [self.users removeObject:seller];
            [self.tableView reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowerTableViewCell *cell = (FollowerTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.delegate = self;
    [cell allowUnfollow:YES];
    return cell;
}

#pragma mark - FollowerTableViewCellDelegate
- (void)unfollow:(id)sender andSeller:(SellerModel *)sellerModel {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateFollowThisSeller:threadObj:) argument:sellerModel];
}
@end
