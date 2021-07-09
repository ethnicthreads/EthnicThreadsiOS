//
//  WishlistViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/2/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "WishlistItemsViewController.h"
#import "UIAlertView+Custom.h"

@interface WishlistItemsViewController () <SlideNavigationControllerDelegate>

@end

@implementation WishlistItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldRefreshItems = ITEMS_GETNEW;
    [self refreshItemsIfNeed:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    CGRect rect = CGRectMake(15, 5, 40, 50);
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:rect];
    
    [self setNavigationBarTitle:NSLocalizedString(@"wishlist", @"") andTextColor:BLACK_COLOR_TEXT];
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

- (Response *)connectToServerToGetItems {
    return [CloudManager getItemsInWishlistFromPage:self.downLoadingPage andPer:PER_COUNT];
}

- (void)executeRemoveItemFromWishlist:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager wishlishItem:[item getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self removeAnItemAndRefreshTableView:item];
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_WISHLISTED_ITEM_NOTIFICATION object:nil userInfo:userInfo];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableViewCell *cell = (ItemTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell setInWishlistPage:YES];
    return cell;
}

#pragma mark - ItemTableViewCellDelegate
- (void)removeItemFromWishlist:(ItemModel *)item {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                                        message:NSLocalizedString(@"alert_remove_item_from_wishlist_confirm", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alertView.context = item;
    alertView.tag = UNWISHLIST_ALERT_TAG;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == UNWISHLIST_ALERT_TAG) {
        if (buttonIndex == 1) {
            ItemModel *item = alertView.context;
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeRemoveItemFromWishlist:threadObj:) argument:item];
        }
    }
    else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - ItemTableViewCellDelegate
 - (void)wishlistItem:(ItemModel *)item {
     [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeRemoveItemFromWishlist:threadObj:) argument:item];
 }
@end
