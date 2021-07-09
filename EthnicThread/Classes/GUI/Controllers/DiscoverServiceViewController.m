//
//  DiscoverServiceViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 3/5/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "DiscoverServiceViewController.h"
#import "DiscoverRightNavigationView.h"
#import "SearchViewController.h"
#import "LocationManager.h"
#import "InviteFriendViewController.h"
#import "NotificationsViewController.h"

@interface DiscoverServiceViewController () <SlideNavigationControllerDelegate, DiscoverRightNavigationViewDelegate>
@property (nonatomic, strong) DiscoverRightNavigationView *rightBar;
@end

@implementation DiscoverServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateBadgesUI:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgesUI:) name:UPDATE_BADGE_NUMBER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initComponentUI {
    [super initComponentUI];
    NSString *title = (IS_IPHONE_5 | IS_IPHONE_4) ? NSLocalizedString(@"discover_services", @"") : [NSString stringWithFormat:@"       %@", NSLocalizedString(@"discover_services", @"")];
    [self setNavigationBarTitle:title andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:CGRectMake(15, 5, 40, 50)];
    self.rightBar = [[[UINib nibWithNibName:NSStringFromClass([DiscoverRightNavigationView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.rightBar.delegate = self;
    [self.rightBar hiddenNotificationIcon:![[UserManager sharedInstance] isLogin]];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] init];
    rightBarButtonItem.customView = self.rightBar;
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}

//- (Response *)connectToServerToGetItems {
//    NSString *country = [self handleGetCountryLogic];
//    
//    PromotionCriteria *criteria = [self.horizontalBar getCurrentSelectedCriteria];
//    if (![[self.horizontalBar getCurrentSelectedCriteria].displayText isEqualToString:NSLocalizedString(@"promotion_all", @"")] && criteria) {
//        if ([[self.horizontalBar getCurrentSelectedCriteria].promotionType.lowercaseString hasPrefix:@"l"]) {
//            //Limited type product
//            CLLocation *location = [self getCurrentLocation];
//            return [CloudManager getItemsWithLimitedCriteria:[criteria.id description] isService:YES country:country fromPage:self.downLoadingPage andPer:PER_COUNT radius:50 location:location];
//        }
//        return [CloudManager getItemsWithCriteria:[criteria.id description] isService:YES country:country fromPage:self.downLoadingPage andPer:PER_COUNT];
//    } else {
//        return [CloudManager getItems:YES country:country fromPage:self.downLoadingPage andPer:PER_COUNT];
//    }
//}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

- (IBAction)handleShareThisAppButton:(id)sender {
    [[AppManager sharedInstance] shareThisApp:self];
}

- (IBAction)handlePostSomethingButton:(id)sender {
    [self openPostSomethingPage];
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

- (void)didLogInNotification:(NSNotification *)noti {
    [super didLogInNotification:noti];
    [self.rightBar hiddenNotificationIcon:NO];
    [self updateBadgesUI:nil];
}

- (void)didLogOutNotification:(NSNotification *)noti {
    [super didLogOutNotification:noti];
    [self.rightBar hiddenNotificationIcon:YES];
}

#pragma mark - DiscoverRightNavigationViewDelegate
//- (void)searchItems {
//    SearchViewController *vc = [[SearchViewController alloc] init];
//    vc.isService = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)inviteFriend {
    if ([[UserManager sharedInstance] isLogin]) {
        InviteFriendViewController *vc = [[InviteFriendViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [self showAlertToRequireLogin:nil];
    }
}

- (void)openListRemoteNotification {
    NotificationsViewController *vc = [[NotificationsViewController alloc] init];
    vc.items = [self getAllItems];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
