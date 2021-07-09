//
//  MenuViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/19/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "MenuViewController.h"
#import "HowItWorksViewController.h"
#import "SignupViewController.h"
#import "AvatarButton.h"
#import "CreateProfileStep1ViewController.h"
#import "SearchViewController.h"
#import "AddItemRequitedViewController.h"
#import "ListedItemsViewController.h"
#import "InboxViewController.h"
#import "FollowersViewController.h"
#import "IAmFollowingViewController.h"
#import "WishlistItemsViewController.h"
#import "InviteFriendViewController.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "UIAlertView+Custom.h"
#import "PreviewItemViewController.h"
#import "MainMenuTableViewCell.h"
#import "DiscoverServiceViewController.h"
#import "FaqViewController.h"
#import "PromotionCriteria.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, ChannelProtocol> {
    MAIN_MENU currentMenuItem;
}

@property (nonatomic, assign) IBOutlet AvatarButton         *btnAvatar;
@property (nonatomic, assign) IBOutlet UILabel              *lblUser;
@property (nonatomic, assign) IBOutlet UIButton             *btnProfile;
@property (nonatomic, assign) IBOutlet UIButton             *btnLogin;
@property (nonatomic, assign) IBOutlet UIButton             *btnLogout;
@property (nonatomic, assign) IBOutlet UITableView          *tableView;

@property (nonatomic, strong) NSMutableArray                *menuSections;
@property (nonatomic, strong) NSIndexPath                   *discoverIndexPath;
@property (nonatomic, strong) NSIndexPath                   *discoverSerivceIndexPath;
@property (nonatomic, strong) NSIndexPath                   *searchIndexPath;

@property (nonatomic, assign) id <NSObject>                 notificationObserver;

- (IBAction)handleProfileButton:(id)sender;
- (IBAction)handleSignupButton:(id)sender;
- (IBAction)handleLogoutButton:(id)sender;
@end

@implementation MenuViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.view isKindOfClass:[ImageBgView class]]) {
        [((ImageBgView *)self.view).bgImageView setImage:[UIImage imageNamed:@"start_page_bg"]];
    }
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _menuSections = [NSMutableArray arrayWithArray:@[@(HOW_IT_WORKS),
                                                     @(HAVING_TROUBLE),
                                                     @(MN_NONE),
                                                     @(DISCOVER),
                                                     @(DISCOVER_SERVICES),
                                                     @(WISHLIST),
                                                     @(POST_SOMETHING),
                                                     @(LISTED_ITEM),
                                                     @(MN_NONE),
                                                     @(INVITE),
                                                     @(INBOX),
                                                     @(FOLLOWERS),
                                                     @(FOLLOWING),
                                                     @(MN_NONE),
                                                     @(FAQ),
                                                     @(CONTACT_US),
                                                     @(VERSION)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogInNotification:) name:DID_LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOutNotification:) name:DID_LOGOUT_NOTIFICATION object:nil];
    self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification *note) {
                                                                                  UIViewController *topVc = [[SlideNavigationController sharedInstance] topViewController];
                                                                                  [(BaseViewController *)topVc willOpenLeftMenu];
                                                                              }];
    [[EventManager shareInstance] addListener:self channel:CHANNEL_UI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver
                                                    name:SlideNavigationControllerDidReveal
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    currentMenuItem = DISCOVER;
    if (!self.discoverVC) {
        // This is the first launch ever
        currentMenuItem = HOW_IT_WORKS;
    }
    self.discoverServiceVC = [[DiscoverServiceViewController alloc] init];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self updateUIUserStatus];
    [self.btnAvatar boderWidth:1 andColor:[UIColor whiteColor].CGColor];
}

- (void)willOpenLeftMenu {
    [self updateUIUserStatus];
}

#pragma mark - Notification Center
- (void)didLogInNotification:(NSNotification *)noti {
    [self.tableView reloadData];
    [self.btnAvatar displayDefaultImage];
    [self updateUIUserStatus];
}

- (void)didLogOutNotification:(NSNotification *)noti {
    if ([self checkActiveMenu:currentMenuItem] == NO) {
        [self openDiscoverPage:nil];
    }
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
    
    [self.tableView reloadData];
    [self updateUIUserStatus];
    [[CachedManager sharedInstance] clearCachedResponeData];
}

#pragma mark - Private Method
- (void)enableControls:(BOOL)logedIn {
    [self.btnAvatar setHidden:!logedIn];
    [self.lblUser setHidden:!logedIn];
    [self.btnProfile setHidden:!logedIn];
    [self.btnLogout setHidden:!logedIn];
    [self.btnLogin setHidden:logedIn];
}

- (void)updateUIUserStatus {
    UserManager *userManager = [UserManager sharedInstance];
    [self enableControls:[userManager isLogin]];
    self.lblUser.text = [[userManager getAccount] getDisplayName];
    [self.btnAvatar loadImageForUrl:[[UserManager sharedInstance] getAccount].avatar];
}

- (void)updateMenuStatus:(MAIN_MENU)menu {
    currentMenuItem = menu;
    [self.tableView reloadData];
}

- (NSString *)valueBy:(MAIN_MENU)menuItem {
    switch (menuItem) {
        case SEARCH:
            return NSLocalizedString(@"search", @"");
        case DISCOVER:
            return NSLocalizedString(@"discover", @"");
        case DISCOVER_SERVICES:
            return NSLocalizedString(@"discover_services", @"");
        case HOW_IT_WORKS:
            return NSLocalizedString(@"how_it_works", @"");
        case WISHLIST:
            return NSLocalizedString(@"wishlist", @"");
        case FOLLOWERS:
            return NSLocalizedString(@"my_followers", @"");
        case POST_SOMETHING:
            return NSLocalizedString(@"post_something", @"");
        case LISTED_ITEM:
            return NSLocalizedString(@"my_postings", @"");
        case INBOX:
            return NSLocalizedString(@"inbox", @"");
        case INVITE:
            return NSLocalizedString(@"invite_friends", @"");
        case FOLLOWING:
            return NSLocalizedString(@"following", @"");
        case FAQ:
            return NSLocalizedString(@"faq", @"");
        case CONTACT_US:
            return NSLocalizedString(@"contact_us", @"");
        case HAVING_TROUBLE:
            return NSLocalizedString(@"having_trouble", @"");
        case VERSION:{
            NSString *versionText = nil;
#ifdef CONFIGURATION_QA
            versionText = @"QA";
#elif CONFIGURATION_DEBUG
            versionText = @"DEBUG";
#else
            versionText = @"";
#endif
            return [NSString stringWithFormat:@"%@: %@%@", NSLocalizedString(@"version", @"QA"), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], versionText];
        }
        default:
            return @"";
            break;
    }
}

- (IBAction)handleProfileButton:(id)sender {
    [self openCreateProfilePage];
}

- (IBAction)handleSignupButton:(id)sender {
    self.discoverVC.shouldRefreshItems = ITEMS_GETNEW;
    [self openLoginPage:nil];
}

- (IBAction)handleLogoutButton:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"logout", @""), nil];
    [sheet showInView:self.view];
}

- (void)openCreateProfilePage {
    CreateProfileStep1ViewController *vc = [[CreateProfileStep1ViewController alloc] init];
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                          withSlideOutAnimation:YES
                                                                  andCompletion:nil];
    vc.creativeAccount = [[UserManager sharedInstance] getCreativeAccount];
    for (MainMenuTableViewCell *cell in [self.tableView visibleCells]) {
        cell.lblText.highlighted = NO;
    }
    currentMenuItem = MN_NONE;
}

- (void)openDiscoverPage:(void (^)())completion {
    for (MainMenuTableViewCell *cell in [_tableView visibleCells]) {
        cell.lblText.highlighted = NO;
    }
    MainMenuTableViewCell *cell = (MainMenuTableViewCell *)[_tableView cellForRowAtIndexPath:_discoverIndexPath];
    cell.lblText.highlighted = YES;
    currentMenuItem = DISCOVER;
    
    if (!self.discoverVC) {
        self.discoverVC = [[DiscoverViewController alloc] init];
    }
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:self.discoverVC
                                                          withSlideOutAnimation:YES
                                                                  andCompletion:(^(void) {
        if (completion != nil) {
            completion();
        }
    })];
}

- (void)openDiscoverScreen:(MAIN_MENU)openScreen criteria:(PromotionCriteria *)criteria {
    for (MainMenuTableViewCell *cell in [_tableView visibleCells]) {
        cell.lblText.highlighted = NO;
    }
    MainMenuTableViewCell *cell = nil;
    ItemsViewController *vc = nil;
    if (openScreen == DISCOVER_SERVICES) {
        cell = (MainMenuTableViewCell *)[_tableView cellForRowAtIndexPath:_discoverSerivceIndexPath];
        vc = [self getDiscoverServiceVC];
    } else if (openScreen == DISCOVER) {
        cell = (MainMenuTableViewCell *)[_tableView cellForRowAtIndexPath:_discoverIndexPath];
        vc = [self getDiscoverStylesVC];
    }
    cell.lblText.highlighted = YES;
    currentMenuItem = openScreen;
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:^{
        [vc didSelectCriteria:criteria];
    }];
}

- (void)openPostSomethingPage {
    if ([[[UserManager sharedInstance] getAccount] checkRequiredFields]) {
        UIViewController *topVc = [SlideNavigationController sharedInstance].topViewController;
        if ([topVc isKindOfClass:[PreviewItemViewController class]] || [topVc isKindOfClass:[AddItemRequitedViewController class]]) {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        }
        else {
            AddItemRequitedViewController *vc = [[AddItemRequitedViewController alloc] init];
            vc.createdItem = [[CreativeItemModel alloc] init];
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                                  withSlideOutAnimation:YES
                                                                          andCompletion:nil];
        }
        currentMenuItem = POST_SOMETHING;
        [self.tableView reloadData];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_info", @"")
                                                        message:NSLocalizedString(@"alert_must_complete_profile", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
        [alert show];
    }
}

- (void)openLoginPage:(NSDictionary *)userInfo {
    SignupViewController *vc = [[SignupViewController alloc] init];
    vc.userInfo = userInfo;
    UIViewController *topVc = [[SlideNavigationController sharedInstance] topViewController];
    vc.transitioningDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [vc.view setFrame:self.view.frame];
    [topVc presentViewController:vc animated:YES completion:nil];
}

- (void)sendEmail:(NSString *)subject messageBody:(NSString *)messageBody toRecipients:(NSArray *)toRecipients {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subject];
        [mail setMessageBody:messageBody isHTML:NO];
        [mail setToRecipients:toRecipients];
        
        UIViewController *topVc = [[SlideNavigationController sharedInstance] topViewController];
        mail.transitioningDelegate = self;
        mail.modalPresentationStyle = UIModalPresentationCustom;
        mail.view.frame = topVc.view.frame;
        [topVc presentViewController:mail animated:YES completion:nil];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_sorry", @"") message:NSLocalizedString(@"alert_sent_mail_dont_support", @"")];
    }
}

- (BOOL)checkActiveMenu:(MAIN_MENU)menu {
    if (menu == POST_SOMETHING || menu == LISTED_ITEM || menu == INBOX ||
        menu == FOLLOWERS || menu == FOLLOWING || menu == WISHLIST || menu == INVITE) {
        return [[UserManager sharedInstance] isLogin];
    }
    if (menu == MN_NONE) {
        return NO;
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logOut];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuSections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *menuCellIdentifier = @"MainMenuCell";
    MainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier];
    if (!cell) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([MainMenuTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.lblText setTextColor:[UIColor whiteColor]];
        cell.lblText.highlightedTextColor = PURPLE_COLOR;
    }
    
    MAIN_MENU menu = [[self.menuSections objectAtIndex:indexPath.row] intValue];
    if (menu == currentMenuItem) {
        cell.lblText.highlighted = YES;
    }
    if (menu == DISCOVER) {
        _discoverIndexPath = indexPath;
    }
    else if (menu == SEARCH) {
        _searchIndexPath = indexPath;
    } else if (menu == DISCOVER_SERVICES) {
        _discoverSerivceIndexPath = indexPath;
    }
    else {
        if ([self checkActiveMenu:menu]) {
            [cell.lblText setTextColor:[UIColor whiteColor]];
        }
        else {
            [cell.lblText setTextColor:[UIColor grayColor]];
        }
    }
    
    if (menu == VERSION) {
        cell.lblText.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
        UILongPressGestureRecognizer *gesture = [[ UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showServerDomain)];
        [cell addGestureRecognizer:gesture];
        [gesture setMinimumPressDuration:5];
    }
    else {
        cell.lblText.font = [UIFont systemFontOfSize:LARGE_FONT_SIZE];
    }
    
    //    if (menu == INBOX) {
    //        NSInteger messages = [[[NSUserDefaults standardUserDefaults] objectForKey:NUMBER_OF_UNREAD_MESSAGES_KEY] integerValue];
    //        [cell setBadgesNumber:messages];
    //    }
    
    NSString *value = [self valueBy:menu];
    cell.lblText.text = value;
    return cell;
}

- (void)showServerDomain {
    NSString *messgae = [NSString stringWithFormat:@"%@ - %@ - %@", [[AppManager sharedInstance] deviceToken], ENVIRONMENT, [[UserManager sharedInstance] getAccount].getIdString];
    [Utils showAlertNoInteractiveWithTitle:[[AppManager sharedInstance] getCloudHostBaseUrl] message:messgae];
}

- (DiscoverServiceViewController *)getDiscoverServiceVC {
    if ([Utils isNilOrNull:self.discoverServiceVC]) {
        self.discoverServiceVC = [[DiscoverServiceViewController alloc] init];
    }
    return self.discoverServiceVC;
}

- (DiscoverViewController *)getDiscoverStylesVC {
    if ([Utils isNilOrNull:self.discoverVC]) {
        self.discoverVC = [[DiscoverViewController alloc] init];
    }
    return self.discoverVC;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MAIN_MENU menu = [[self.menuSections objectAtIndex:indexPath.row] intValue];
    if ([self checkActiveMenu:menu] == NO || menu == VERSION)
        return;
    UIViewController *vc = nil;
    switch (menu) {
        case SEARCH: {
            SearchViewController *searchVc = [[SearchViewController alloc] init];
            searchVc.canBackToMainMenu = YES;
            vc = searchVc;
        }
            break;
        case DISCOVER: {
            [self openDiscoverPage:nil];
        }
            break;
        case DISCOVER_SERVICES: {
            vc = [self getDiscoverServiceVC];
        }
            break;
        case HOW_IT_WORKS: {
            vc = [[HowItWorksViewController alloc] init];
        }
            break;
        case WISHLIST: {
            vc = [[WishlistItemsViewController alloc] init];;
        }
            break;
        case POST_SOMETHING: {
            [self openPostSomethingPage];
        }
            break;
        case LISTED_ITEM: {
            ListedItemsViewController *listedItemVC = [[ListedItemsViewController alloc] init];
            listedItemVC.canBackToMainMenu = YES;
            listedItemVC.userModel = [[UserManager sharedInstance] getAccount];
            listedItemVC.allowEditing = YES;
            vc = listedItemVC;
        }
            break;
        case INBOX: {
            vc = [[InboxViewController alloc] init];
        }
            break;
        case INVITE: {
            InviteFriendViewController *inviteVc = [[InviteFriendViewController alloc] init];
            inviteVc.canBackToMainMenu = YES;
            vc = inviteVc;
        }
            break;
        case FOLLOWERS: {
            FollowersViewController *followerVc = [[FollowersViewController alloc] init];
            followerVc.userModel = [[UserManager sharedInstance] getAccount];
            followerVc.canBackToMainMenu = YES;
            vc = followerVc;
        }
            break;
        case FOLLOWING: {
            vc = [[IAmFollowingViewController alloc] init];
        }
            break;
        case CONTACT_US: {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^(void) {
                [self sendEmail:NSLocalizedString(@"support_request", @"") messageBody:@"" toRecipients:@[CONTACT_US_EMAIL]];
            }];
        }
        case HAVING_TROUBLE: {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^(void) {
                [self sendEmail:NSLocalizedString(@"having_trouble_request", @"") messageBody:@"" toRecipients:@[CONTACT_US_EMAIL]];
            }];
        }
            return;
        case FAQ: {
            vc = [[FaqViewController alloc] init];
        }
            break;
        default:
            break;
    }
    
    currentMenuItem = menu;
    for (MainMenuTableViewCell *cell in [tableView visibleCells]) {
        cell.lblText.highlighted = NO;
    }
    MainMenuTableViewCell *cell = (MainMenuTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.lblText.highlighted = YES;
    if (vc) {
        [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                              withSlideOutAnimation:YES
                                                                      andCompletion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultFailed: {
            [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"") message:NSLocalizedString(@"alert_send_mail_faild", @"")];
        }
            return;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self openCreateProfilePage];
    }
}

- (void)dispatchChannelEvent:(Event *)aEvent {
    if (aEvent.eventType == ET_OPEN_SELLER) {
        NSInteger sellerID = [[aEvent.result objectForKey:ID_KEY] integerValue];
        [self.discoverVC openMyProfilePage:@(sellerID)];
    } else if (aEvent.eventType == ET_OPEN_ITEM) {
        NSInteger itemID = [[aEvent.result objectForKey:ID_KEY] integerValue];
        [self.discoverVC openMoreInfoByItemId:@(itemID) shouldOpenComments:NO];
    }
}
@end
