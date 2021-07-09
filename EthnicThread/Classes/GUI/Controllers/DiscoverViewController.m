//
//  LandingViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "DiscoverViewController.h"
#import "MoreInfoViewController.h"
#import "SellerProfileViewController.h"
#import "MenuViewController.h"
#import "DiscoverRightNavigationView.h"
#import "InviteFriendViewController.h"
#import "SearchViewController.h"
#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "LocationManager.h"
#import "InternalWebViewController.h"

@interface DiscoverViewController () <SlideNavigationControllerDelegate, DiscoverRightNavigationViewDelegate> {
    BOOL shouldDownloadNewItem;
}
@property (weak, nonatomic) IBOutlet UIView *horizontalDiscoverBar;
@property (nonatomic, strong) DiscoverRightNavigationView *rightBar;
@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SlideNavigationController sharedInstance] prepareMenuForReveal:MenuLeft];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateBadgesUI:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgesUI:) name:UPDATE_BADGE_NUMBER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initComponentUI {
    [super initComponentUI];
    CGRect rect = CGRectMake(15, 5, 40, 50);
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:rect];
    
    NSString *title = (IS_IPHONE_5 | IS_IPHONE_4) ? NSLocalizedString(@"discover", @"") : [NSString stringWithFormat:@"        %@", NSLocalizedString(@"discover", @"")];
    [self setNavigationBarTitle:title andTextColor:BLACK_COLOR_TEXT];
    self.rightBar = [[[UINib nibWithNibName:NSStringFromClass([DiscoverRightNavigationView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.rightBar.delegate = self;
    [self.rightBar hiddenNotificationIcon:![[UserManager sharedInstance] isLogin]];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] init];
    rightBarButtonItem.customView = self.rightBar;
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

//- (Response *)connectToServerToGetItems {
//    NSString *country = [self handleGetCountryLogic];
//    
//    PromotionCriteria *criteria = [self.horizontalBar getCurrentSelectedCriteria];
//    if (![[self.horizontalBar getCurrentSelectedCriteria].displayText isEqualToString:NSLocalizedString(@"promotion_all", @"")] && criteria) {
//        if ([[self.horizontalBar getCurrentSelectedCriteria].promotionType.lowercaseString hasPrefix:@"l"]) {
//            //Limited type product
//            CLLocation *location = [self getCurrentLocation];
//            return [CloudManager getItemsWithLimitedCriteria:[criteria.id description] isService:NO country:country fromPage:self.downLoadingPage andPer:PER_COUNT radius:50 location:location];
//        }
//        if ([criteria.promotionType.lowercaseString isEqualToString:@"city"]) {
//            country = nil;
//        }
//        return [CloudManager getItemsWithCriteria:[criteria.id description] isService:NO country:country fromPage:self.downLoadingPage andPer:PER_COUNT];
//    } else {
//        return [CloudManager getItems:NO country:country fromPage:self.downLoadingPage andPer:PER_COUNT];
//    }
//}

- (void)downloadLatestItemsCompleted:(BOOL)itemCount {
    [[AppManager sharedInstance] updateTags:NO andListener:nil];
    [[AppManager sharedInstance] updateAddresses:NO];
}

- (void)openMyProfilePage:(NSNumber *)userId {
    if ([[[[UserManager sharedInstance] getAccount] getIdString] isEqualToString:[userId description]]) {
        SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
        vc.sellerModel = [[UserManager sharedInstance] getAccount];
        vc.shouldAutoLoadReviews = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUserProfile:threadObj:) argument:[userId description]];
    }
}

- (void)openMoreInfoByItemId:(NSNumber *)itemId shouldOpenComments:(BOOL)shouldOpenComments {
    ItemModel *item = [self getIemById:itemId];
    if (item) {
        MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
        vc.avatarImage = [[DownloadManager shareInstance] getCachedImageForUrl:item.sellerModel.avatar];
        vc.firstImage = [[DownloadManager shareInstance] getCachedImageForUrl:[item getFirstImageUrl]];
        vc.itemModel = item;
        vc.shouldAutoLoadComments = shouldOpenComments;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSArray *array = [NSArray arrayWithObjects:itemId, @(shouldOpenComments), nil];
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadItem:threadObj:) argument:array];
    }
}

- (void)openAdvertisingUrl:(NSString *)url {
    InternalWebViewController *vc = [[InternalWebViewController alloc] init];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didLogInNotification:(NSNotification *)noti {
    [super didLogInNotification:noti];
    [self.rightBar hiddenNotificationIcon:NO];
    [self updateBadgesUI:nil];
}

- (void)didLogOutNotification:(NSNotification *)noti {
    [super didLogOutNotification:noti];
    [self.rightBar hiddenNotificationIcon:YES];
}

- (IBAction)handleShareThisAppButton:(id)sender {
    [[AppManager sharedInstance] shareThisApp:self];
}

- (IBAction)handlePostSomethingButton:(id)sender {
    [self openPostSomethingPage];
}

#pragma mark - Private Method
- (void)executeDownloadItem:(NSArray *)argArray threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getItemsByIds:[argArray objectAtIndex:0]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSArray *array = response.getJsonObject;
        ItemModel *item = [[ItemModel alloc] initWithDictionary:[array firstObject]];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
            vc.itemModel = item;
            [vc setShouldAutoLoadComments:[[argArray objectAtIndex:1] boolValue]];
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeUserProfile:(NSString *)userId threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getUserProfile:userId];
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

#pragma mark - Notification Center
- (void)updateBadgesUI:(NSNotification *)noti {
    AccountModel *account = [[UserManager sharedInstance] getAccount];
    NSInteger badge = account ? account.unread_notifications : 0;
    [self.rightBar setBadges:badge];
}

- (void)willEnterForeground:(NSNotification *)noti {
    [self updateBadgesUI:nil];
}

#pragma mark - DiscoverRightNavigationViewDelegate
- (void)inviteFriend {
    if ([[UserManager sharedInstance] isLogin]) {
        InviteFriendViewController *vc = [[InviteFriendViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [self showAlertToRequireLogin:nil];
    }
}

//- (void)searchItems {
//    SearchViewController *vc = [[SearchViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)openListRemoteNotification {
    NotificationsViewController *vc = [[NotificationsViewController alloc] init];
    vc.items = [self getAllItems];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}
@end
