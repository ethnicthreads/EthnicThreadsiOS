//
//  InboxViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "InboxViewController.h"
#import "ThreadTableViewCell.h"
#import "ThreadModel.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "ContactSellerViewController.h"
#import "NSMutableArray+SWUtilityButtons.h"
#import "UIAlertView+Custom.h"

#define PER_COUNT               10

@interface InboxViewController () <SlideNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, ContactSellerViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, assign) IBOutlet UITableView      *tableView;
@property (nonatomic, strong) NSMutableArray            *threads;
@property (nonatomic, assign) NSInteger                 downloadingPage;
@property (nonatomic, assign) id<OperationProtocol>     messageThread;
@end

@implementation InboxViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.downloadingPage = 1;
    self.threads = [[NSMutableArray alloc] init];
    NSMutableArray *array = [self getCacheThreads];
    if (array.count > 0) {
        for (NSDictionary *dict in array) {
            ThreadModel *thread = [[ThreadModel alloc] initWithDictionary:dict];
            if (thread) {
                [self.threads addObject:thread];
            }
        }
    }
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:NSLocalizedString(@"inbox", @"") andTextColor:BLACK_COLOR_TEXT];
    CGRect rect = CGRectMake(15, 5, 40, 50);
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:rect];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadThreads:threadObj:) argument:@""];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView addPullToRefreshWithActionHandler:^(void) {
        [self.messageThread cancel];
        self.messageThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadThreadsByPullToRefresh:threadObj:) argument:@""];
    }
                                             position:SVPullToRefreshPositionTop];
    [self.tableView addInfiniteScrollingWithActionHandler:^(void) {
        [self.messageThread cancel];
        self.messageThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadThreadsAndInsertPositionBottom:threadObj:) argument:@""];
    }];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:PURPLE_COLOR title:@"Delete"];
    return rightUtilityButtons;
}

- (void)downloadThreads:(NSInteger)page andPer:(NSInteger)per isRefresh:(BOOL)refresh shouldShowErrorAlert:(BOOL)shouldShowErrorAlert threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager getThreadsFromPage:page andPer:per];
    
    if (![threadObj isCancelled] && [self isResponseSuccessful:response shouldShowAlert:shouldShowErrorAlert]) {
        NSArray *array = response.getJsonObject;
        [self cacheThreads:array byAppend:!refresh];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            ThreadModel *thread = [[ThreadModel alloc] initWithDictionary:dict];
            if (thread) {
                [results addObject:thread];
            }
        }
        if (refresh) {
            [self.tableView setShowsInfiniteScrolling:(results.count > 7)];// table contains 6 visible rows
        }
        if (results.count > 0) {
            if (refresh) {
                [self.tableView setShowsInfiniteScrolling:(results.count > 7)];// table contains 6 visible rows
                self.downloadingPage = 2;
                [self.threads removeAllObjects];
            } else {
                // increasing page for next request
                self.downloadingPage++;
            }
            [self.threads addObjectsFromArray:results];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadData];
        });
    }
}

- (void)executeDownloadThreads:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    [self downloadThreads:self.downloadingPage andPer:PER_COUNT isRefresh:YES shouldShowErrorAlert:YES threadObj:threadObj];
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadThreadsByPullToRefresh:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    self.downloadingPage = 1;
    [self downloadThreads:self.downloadingPage andPer:PER_COUNT isRefresh:YES shouldShowErrorAlert:NO threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.pullToRefreshView stopAnimating];
    });
    [threadObj releaseOperation];
}

- (void)executeDownloadThreadsAndInsertPositionBottom:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self downloadThreads:self.downloadingPage andPer:PER_COUNT isRefresh:NO shouldShowErrorAlert:NO threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.infiniteScrollingView stopAnimating];
    });
    [threadObj releaseOperation];
}

- (void)executeDeleteAThread:(ThreadModel *)threadModel threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager deleteThread:[[threadModel getTargetSeller] getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSMutableArray *array = [self getCacheThreads];
        for (NSDictionary *dict in array) {
            if ([[threadModel getIdString] isEqualToString:[[dict objectForKey:@"id"] description]]) {
                [array removeObject:dict];
                [self cacheThreads:array byAppend:NO];
                break;
            }
        }
        [self.threads removeObject:threadModel];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)cacheThreads:(NSArray *)threadJson byAppend:(BOOL)append {
    if (threadJson.count == 0) return;
    NSData *jsonData = nil;
    if (append) {
         NSMutableArray *threads = [self getCacheThreads];
        [threads addObjectsFromArray:threadJson];
        jsonData = [NSJSONSerialization dataWithJSONObject:threads options:0 error:nil];
    }
    else {
        jsonData = [NSJSONSerialization dataWithJSONObject:threadJson options:0 error:nil];
    }
    [[CachedManager sharedInstance] cacheData:jsonData key:@"downloaded_threads" type:CT_RESPONSE];
}

- (NSMutableArray *)getCacheThreads {
    NSData *jsonData = [[CachedManager sharedInstance] getCachedDataForKey:@"downloaded_threads" type:CT_RESPONSE];
    if (jsonData) {
        NSError *error = nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (!error && array.count > 0) {
            return [NSMutableArray arrayWithArray:array];
        }
    }
    return nil;
}

- (void)openContactPageWithUser:(NSNumber *)userId andFulName:(NSString *)fullName {
    ContactSellerViewController *vc = [[ContactSellerViewController alloc] init];
    vc.userId = [userId description];
    vc.fullName = fullName;
    vc.shouldMarkOpened = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.threads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *threadCellIdentifier = @"ThreadCell";
    ThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:threadCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ThreadTableViewCell class]) owner:nil options:nil] objectAtIndex:0];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:100.0f];
        cell.delegate = self;
    }
    ThreadModel *thread = [self.threads objectAtIndex:indexPath.row];
    [cell setThread:thread];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadModel *thread = [self.threads objectAtIndex:indexPath.row];
    [thread justOpened];
    ContactSellerViewController *vc = [[ContactSellerViewController alloc] init];
    vc.threadModel = thread;
    vc.delegate = self;
    vc.shouldMarkOpened = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                                        message:NSLocalizedString(@"alert_delete_thread_confirm", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alertView.context = [(ThreadTableViewCell *)cell thread];
    [alertView show];
}

#pragma mark - ContactSellerViewControllerDelegate
- (void)updateThread:(MessageModel *)message {
    for (ThreadModel *thread in self.threads) {
        if ([thread checkMessageBelong:message]) {
            [thread updateWithMessage:message];
        }
    }
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDeleteAThread:threadObj:) argument:alertView.context];
    }
}
@end
