//
//  UsersViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UsersViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface UsersViewController ()
@property (nonatomic, assign) id<OperationProtocol>         userThread;
@end

@implementation UsersViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.users = [[NSMutableArray alloc] init];
    self.downLoadingPage = 1;
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_menu"]
                       andFrame:CGRectMake(15, 5, 40, 50)];
    
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadUsers:threadObj:) argument:@""];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView addPullToRefreshWithActionHandler:^(void) {
        [self.userThread cancel];
        self.userThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeRefreshUsers:threadObj:) argument:@""];
    }
                                             position:SVPullToRefreshPositionTop];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^(void) {
        [self.userThread cancel];
        self.userThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadUsersAndInsertPositionBottom:threadObj:) argument:@""];
    }];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

- (Response *)connectToServer {
    return nil;
}

- (void)downloadUsers:(BOOL)shouldShowErrorAlert threadObj:(id<OperationProtocol>)threadObj {
    self.downLoadingPage = 1;
    Response *response = [self connectToServer];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response shouldShowAlert:shouldShowErrorAlert]) {
        NSArray *array = response.getJsonObject;
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            SellerModel *seller = [[SellerModel alloc] initWithDictionary:dict];
            if (seller) {
                [results addObject:seller];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView setShowsInfiniteScrolling:(self.users.count > 6)];// table contains 6 visible rows
        });
        if (results.count > 0) {
            self.downLoadingPage++;
            self.users = [NSMutableArray arrayWithArray:results];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.tableView reloadData];
            });
        }
    }
}

- (void)executeDownloadUsers:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    [self downloadUsers:YES threadObj:threadObj];
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeRefreshUsers:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self downloadUsers:NO threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.pullToRefreshView stopAnimating];
    });
    [threadObj releaseOperation];
}

- (void)executeDownloadUsersAndInsertPositionBottom:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [self connectToServer];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response shouldShowAlert:NO]) {
        NSArray *array = response.getJsonObject;
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            SellerModel *seller = [[SellerModel alloc] initWithDictionary:dict];
            if (seller) {
                [results addObject:seller];
            }
        }
        
        if (results.count > 0) {
            // increasing page for next request
            self.downLoadingPage++;
            [self.users addObjectsFromArray:results];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [_tableView reloadData];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.infiniteScrollingView stopAnimating];
    });
    [threadObj releaseOperation];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *threadCellIdentifier = @"FollowerCell";
    FollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:threadCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FollowerTableViewCell class]) owner:nil options:nil] objectAtIndex:0];
    }
    SellerModel *seller = [self.users objectAtIndex:indexPath.row];
    cell.sellerModel = seller;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    SellerModel *seller = [self.users objectAtIndex:indexPath.row];
    vc.sellerModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
