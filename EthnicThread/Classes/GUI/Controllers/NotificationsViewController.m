//
//  NotificationsViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 3/9/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationTableViewCell.h"
#import "AppManager.h"
#import "NotificationModel.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "ContactSellerViewController.h"
#import "SellerProfileViewController.h"
#import "MoreInfoViewController.h"

#define PER_COUNT               20

@interface NotificationsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) IBOutlet UITableView      *tableView;
@property (nonatomic, strong) NSMutableArray            *notifs;
@property (nonatomic, assign) id<OperationProtocol>     thread;
@property (nonatomic, assign) NSInteger                 downloadingPage;
@property (nonatomic, strong) NSMutableArray            *downloadedItems;
@property (nonatomic, assign) IBOutlet UIButton         *btnMarkAll;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *lcHeightMarkAllButton;
@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)initVariables {
    [super initVariables];
    self.downloadingPage = 1;
    self.notifs = [[NSMutableArray alloc] init];
    self.downloadedItems = [[NSMutableArray alloc] init];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"notifications", @"") andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_back_button"] andFrame:CGRectMake(15, 5, 40, 50)];
    if ([[UserManager sharedInstance] getAccount].unread_notifications == 0) {
        self.lcHeightMarkAllButton.constant = 0;
        [self.btnMarkAll setHidden:YES];
    }
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadNotifications:threadObj:) argument:@""];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView addInfiniteScrollingWithActionHandler:^(void) {
        [self.thread cancel];
        self.thread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadNotificationAndInsertPositionBottom:threadObj:) argument:@""];
    }];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleMarkAllButton:(id)sender {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDismissAllNotificaions:threadObj:) argument:@""];
}

#pragma mark - Private Methods
- (ItemModel *)getIemById:(NSString *)itemId {
    for (ItemModel *item in self.items) {
        if ([itemId isEqualToString:[item getIdString]]) {
            return item;
        }
    }
    for (ItemModel *item in self.downloadedItems) {
        if ([itemId isEqualToString:[item getIdString]]) {
            return item;
        }
    }
    return nil;
}

- (void)downloadThreads:(NSInteger)page andPer:(NSInteger)per isRefresh:(BOOL)refresh threadObj:(id<OperationProtocol>)threadObj {
    REQUEST_TYPE requestType = RQ_SAVEDATA | RQ_GETCACHEIFFAILED;
    Response *response = [CloudManager getNotificatiosFromPage:page andPer:per requestType:requestType];
    
    if (![threadObj isCancelled] && [self isResponseSuccessful:response shouldShowAlert:refresh]) {
        NSArray *array = response.getJsonObject;
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            NotificationModel *notif = [[NotificationModel alloc] initWithDictionary:dict];
            if (notif) {
                [results addObject:notif];
            }
        }
        if (refresh) {
            [self.tableView setShowsInfiniteScrolling:(results.count > 7)];// table contains 6 visible rows
        }
        if (results.count > 0) {
            if (refresh) {
                self.downloadingPage = 2;
                [self.notifs removeAllObjects];
            } else {
                // increasing page for next request
                self.downloadingPage++;
            }
            [self.notifs addObjectsFromArray:results];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadData];
        });
    }
}

- (void)executeDownloadNotifications:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    [self downloadThreads:self.downloadingPage andPer:PER_COUNT isRefresh:YES threadObj:threadObj];
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadNotificationAndInsertPositionBottom:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self downloadThreads:self.downloadingPage andPer:PER_COUNT isRefresh:NO threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.infiniteScrollingView stopAnimating];
    });
    [threadObj releaseOperation];
}

- (void)executeDismissNotificaion:(NotificationModel *)notif threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager dismissNotification:[notif getIdString]];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        notif.dismissed = YES;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadData];
            AccountModel *acount = [[UserManager sharedInstance] getAccount];
            if (acount.unread_notifications == 1) {
                self.lcHeightMarkAllButton.constant = 0;
                [self.btnMarkAll setHidden:YES];
            }
            [acount setUnread_notifications:acount.unread_notifications - 1];
        });
    }
    [threadObj releaseOperation];
}

- (void)executeDismissAllNotificaions:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager dismissAllNotifications];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        for (NotificationModel *notif in self.notifs) {
            notif.dismissed = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.lcHeightMarkAllButton.constant = 0;
            [self.btnMarkAll setHidden:YES];
            [self.tableView reloadData];
            [[[UserManager sharedInstance] getAccount] setUnread_notifications:0];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadItem:(NotificationModel *)notif threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getItemsByIds:[notif getItemId]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSArray *array = response.getJsonObject;
        ItemModel *item = [[ItemModel alloc] initWithDictionary:[array firstObject]];
        if (item) {
            [self.downloadedItems addObject:item];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
                vc.itemModel = item;
                [vc setShouldAutoLoadComments:(notif.type == PNT_COMMENT)];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeUserProfile:(NotificationModel *)notif threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getUserProfile:[notif getSenderId]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        SellerModel *seller = [[SellerModel alloc] initWithDictionary:response.getJsonObject];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
            vc.sellerModel = seller;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reviewCellIdentifier = @"NotificationCell";
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reviewCellIdentifier];
    if (!cell) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([NotificationTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    NotificationModel *notif = [self.notifs objectAtIndex:indexPath.row];
    cell.notif = notif;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationModel *notif = [self.notifs objectAtIndex:indexPath.row];
    if (notif.type == PNT_MESSAGE) {
        ContactSellerViewController *vc = [[ContactSellerViewController alloc] init];
        vc.userId = [notif getSenderId];
        vc.fullName = [notif getSenderFullName];
        vc.shouldMarkOpened = YES;
        [self.navigationController pushViewController:vc animated:NO];
    }
    else if (notif.type == PNT_COMMENT || notif.type == PNT_LIKE || notif.type == PNT_SELLINGITEM) {
        ItemModel *item = [self getIemById:[notif getItemId]];
        if (item) {
            MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
            vc.avatarImage = [[DownloadManager shareInstance] getCachedImageForUrl:item.sellerModel.avatar];
            vc.firstImage = [[DownloadManager shareInstance] getCachedImageForUrl:[item getFirstImageUrl]];
            vc.itemModel = item;
            [vc setShouldAutoLoadComments:(notif.type == PNT_COMMENT)];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadItem:threadObj:) argument:notif];
        }
    }
    else if (notif.type == PNT_REVIEW) {
        SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
        vc.sellerModel = [[UserManager sharedInstance] getAccount];
        vc.shouldAutoLoadReviews = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (notif.type == PNT_FOLLOW) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUserProfile:threadObj:) argument:notif];
    }
    
    if (!notif.dismissed) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDismissNotificaion:threadObj:) argument:notif];
    }
}
@end
