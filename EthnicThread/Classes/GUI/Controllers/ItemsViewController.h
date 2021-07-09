//
//  ItemsViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "ItemTableViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "PromotionCriteria.h"
#import "HorizontalDiscoverBar.h"
#import "LocationDiscoverView.h"
#import "CHTCollectionViewWaterfallLayout.h"

#define MODEL_OBJECT_KEY            @"model_object_key"
#define PER_COUNT                   20

typedef enum _REFRESHITEMS {
    ITEMS_DONOTHING,
    ITEMS_RELOAD_SCREEN,
    ITEMS_GETNEW,
    ITEMS_UPDATESTATUS,
    ITEMS_RESETSTATUS
} REFRESHITEMS;

#define UNWISHLIST_ALERT_TAG        101
#define REMOVEITEM_ALERT_TAG        102
#define INAPPROPRIATE_ALERT_TAG     103
#define DELETECOMMENT_ALERT_TAG     104

@interface ItemsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, ItemTableViewCellDelegate,UIViewControllerTransitioningDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, assign) IBOutlet UITableView          *tableView;
@property (nonatomic, assign) NSInteger                     downLoadingPage;
@property (nonatomic) REFRESHITEMS                          shouldRefreshItems;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (nonatomic, strong) HorizontalDiscoverBar         *horizontalBar;
@property (nonatomic, strong) LocationDiscoverView          *locationDiscoverView;
@property (strong, nonatomic) IBOutlet UICollectionView *galleryView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *galleryFlow;


- (Response *)connectToServerToGetItems;
- (void)removeAnItemAndRefreshTableView:(ItemModel *)item;
- (NSMutableArray *)filterItems:(NSMutableArray *)items;
- (void)downloadLatestItemsCompleted:(BOOL)itemCount;
- (ItemModel *)getIemById:(NSNumber *)itemId;
- (void)didLogInNotification:(NSNotification *)noti;
- (void)didLogOutNotification:(NSNotification *)noti;
- (NSArray *)getAllItems;
- (void)openPostSomethingPage;
- (void)refreshItemsIfNeed:(NSDictionary *)userInfo;
- (void)didSelectCriteria:(PromotionCriteria *)selectedCriteria;
- (NSString *)handleGetCountryLogic;
- (CLLocation *)getCurrentLocation;
@end
