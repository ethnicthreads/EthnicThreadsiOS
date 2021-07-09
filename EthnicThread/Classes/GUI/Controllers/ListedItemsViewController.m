//
//  ListedItemsViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ListedItemsViewController.h"
#import "UIAlertView+Custom.h"
#import "PreviewItemViewController.h"
#import "UpdateItemModel.h"
#import "GalleryCollectionViewCell.h"

#define MARKSTATUS_KEY      @"mark_status"

@interface ListedItemsViewController () <SlideNavigationControllerDelegate>

@end

@implementation ListedItemsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

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
    
    NSString *title = NSLocalizedString(@"my_postings", @"");
    if (![self.userModel isMe]) {
        title = [NSString stringWithFormat:@"%@'s %@", [self.userModel getDisplayName], NSLocalizedString(@"listed_items", @"")];
    }
    [self setNavigationBarTitle:title andTextColor:BLACK_COLOR_TEXT];
    
    if (self.canBackToMainMenu) {
        [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:CGRectMake(15, 5, 40, 50)];
    }
    else {
        [self setLeftNavigationItem:@""
                       andTextColor:nil
                     andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                           andFrame:CGRectMake(0, 0, 40, 35)];
    }
}

- (void)handlerLeftNavigationItem:(id)sender {
    if (self.canBackToMainMenu) {
        [self handleTouchToMainMenuButton];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (Response *)connectToServerToGetItems {
    return [CloudManager getItemsBySellerId:[self.userModel getIdString] andFromPage:self.downLoadingPage andPer:PER_COUNT];
}

- (void)executeMarkStatusItem:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    ItemModel *item = [param objectForKey:MODEL_OBJECT_KEY];
    NSString *aNewStatus = [param objectForKey:MARKSTATUS_KEY];
    NSData *data = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObject:aNewStatus forKey:@"status"]
                                                   options:0
                                                     error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager markItem:[item getIdString] andBody:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        item.status = aNewStatus;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadData];
            [self.galleryView reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeRemoveItem:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager removeItem:[item getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            for (UITableViewCell *cell in [self.tableView visibleCells]) {
                [(ItemTableViewCell *)cell closeRightMenu:NO];
            }
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : [item getIdString]};
            [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_ITEM_NOTIFICATION object:nil userInfo:userInfo];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GalleryCollectionViewCell *cell = (GalleryCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    [cell allowEdit];
    return cell;
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return self.canBackToMainMenu;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableViewCell *cell = (ItemTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell setHasRightMenu:self.allowEditing];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        [(ItemTableViewCell *)cell closeRightMenu:YES];
    }
}

#pragma mark - ItemTableViewCellDelegate
- (void)editItem:(ItemModel *)item {
    UpdateItemModel *creativeItem = [[UpdateItemModel alloc] initWithItemModel:item];
    PreviewItemViewController *vc = [[PreviewItemViewController alloc] init];
    vc.createdItem = creativeItem;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateItemStatus:(ItemModel *)item withStatus:(NSString *)status {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:item forKey:MODEL_OBJECT_KEY];
    [dict setObject:status forKey:MARKSTATUS_KEY];
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeMarkStatusItem:threadObj:) argument:dict];
}

- (void)removeItem:(ItemModel *)item {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                                        message:NSLocalizedString(@"alert_delete_item_confirm", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alertView.context = item;
    alertView.tag = REMOVEITEM_ALERT_TAG;
    [alertView show];
}

- (void)buyNow:(ItemModel *)item {
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == REMOVEITEM_ALERT_TAG) {
        if (buttonIndex == 1) {
            ItemModel *item = alertView.context;
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeRemoveItem:threadObj:) argument:item];
        }
    }
    else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}
@end
