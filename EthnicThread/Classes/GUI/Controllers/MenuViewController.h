//
//  MenuViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/19/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "DiscoverViewController.h"
#import "DiscoverServiceViewController.h"
#import "PromotionCriteria.h"

typedef enum _MAIN_MENU {
    MN_NONE,
    PROFILE,
    SEARCH,
    DISCOVER,
    DISCOVER_SERVICES,
    HOW_IT_WORKS,
    WISHLIST,
    FOLLOWERS,
    POST_SOMETHING,
    LISTED_ITEM,
    INBOX,
    INVITE,
    FOLLOWING,
    FAQ,
    CONTACT_US,
    HAVING_TROUBLE,
    VERSION
} MAIN_MENU;

@interface MenuViewController : BaseViewController
@property (nonatomic, strong) DiscoverViewController        *discoverVC;
@property (nonatomic, strong) DiscoverServiceViewController *discoverServiceVC;

- (void)openDiscoverPage:(void (^)())completion;
- (void)openLoginPage:(NSDictionary *)userInfo;
- (void)openDiscoverScreen:(MAIN_MENU)openScreen criteria:(PromotionCriteria *)criteria;
- (void)openCreateProfilePage;
- (void)updateUIUserStatus;
- (void)sendEmail:(NSString *)subject messageBody:(NSString *)messageBody toRecipients:(NSArray *)toRecipients;
- (void)updateMenuStatus:(MAIN_MENU)menu;
- (void)openPostSomethingPage;
@end
