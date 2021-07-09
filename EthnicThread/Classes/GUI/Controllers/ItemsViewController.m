//
//  ItemsViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemsViewController.h"
#import "MoreInfoViewController.h"
#import "SellerProfileViewController.h"
#import "MenuViewController.h"
#import "LikersViewController.h"
#import "UIActionSheet+Custom.h"
#import "ContactSellerViewController.h"
#import "FollowersViewController.h"
#import "ImagePopupViewController.h"
#import "UIAlertView+Custom.h"
#import "HorizontalDiscoverBar.h"
#import "DiscoverServiceViewController.h"
#import "LocationManager.h"
#import "ChannelProtocol.h"
#import "CountriesViewController.h"
#import "DiscoverMoreDiaglog.h"
#import "SearchViewController.h"
#import "DiscoverAllDiaglog.h"
#import "ListedItemsViewController.h"
#import "SellerNamesViewController.h"
#import "GalleryCollectionViewCell.h"

#define HorizontalBarWithLocation 60
#define HorizontalBarWithoutLocation 45
#define ReuseIdentifier @"cell"

@interface ItemsViewController () <ItemModelDelegate, ImagesScrollViewDelegate, ChannelProtocol, CHTCollectionViewDelegateWaterfallLayout, CountriesViewControllerDelegate, UIAlertViewDelegate, CBImageViewProtocol, GalleryCollectionViewCellDelegate, UICollectionViewDataSourcePrefetching>
@property (nonatomic, strong) NSMutableArray                *items;
@property (nonatomic, assign) id<OperationProtocol>         runningThread;
@property (nonatomic, assign) id<OperationProtocol>             itemsThread;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcHeightHorizontalBar;
@property (weak, nonatomic) IBOutlet UIView *horizontalBarContainer;
@property (strong, nonatomic) ItemTableViewCell             *offScreenCell;
@property (strong, nonatomic) IBOutlet UIView *galleryBarView;
@property (strong, nonatomic) UIButton *btnGallery;
@property (strong, nonatomic) UIButton *btnSocialView;
@property (nonatomic, strong) NSMutableArray                *promotionCriterias;
@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[EventManager shareInstance] addListener:self channel:CHANNEL_UI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[self.horizontalBar getCurrentSelectedCriteria] isCriteriaOfProductType] && [self isKindOfClass:[DiscoverServiceViewController class]]) {
        [self.horizontalBar selectCriteriaAtIndex:0];
    } else if ([[self.horizontalBar getCurrentSelectedCriteria] isCriteriaOfTalentType] && [self isKindOfClass:[DiscoverViewController class]]) {
        [self.horizontalBar selectCriteriaAtIndex:0];
    }
    self.shouldRefreshItems = ITEMS_GETNEW;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.downLoadingPage = 1;
    self.shouldRefreshItems = ITEMS_GETNEW;
    self.promotionCriterias = [NSMutableArray array];
    [self.galleryView setHidden:NO];
    [self.tableView setHidden:YES];
    [self.galleryView setDataSource:self];
    [self.galleryView setDelegate:self];
    [self.galleryView setPrefetchDataSource:self];
    [self.galleryView registerClass:[GalleryCollectionViewCell class] forCellWithReuseIdentifier:ReuseIdentifier];
     [self.galleryView registerNib:[UINib nibWithNibName:@"GalleryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:ReuseIdentifier];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    
    [self.galleryView setCollectionViewLayout:layout];
    
    // allow multiple selections
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetPromotionCriteria:threadObj:) argument:@""];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self.tableView setBackgroundColor:UIColorFromRGB(0xb5b4b4)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollowingOfItems:) name:UPDATE_FOLLOWED_USER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRatingOfItems:) name:UPDATE_RATE_USER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWishlistOfItems:) name:UPDATE_WISHLISTED_ITEM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFlagingOfItems:) name:FLAG_ITEM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCommentOfItems:) name:UPDATE_COMMENT_OF_ITEM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikingOfItems:) name:UPDATE_LIKED_ITEM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateItem:) name:UPDATE_ITEM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name:DELETE_ITEM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willLogInNotification:) name:WILL_LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogInNotification:) name:DID_LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOutNotification:) name:DID_LOGOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation) name:UPDATE_CURRENT_LOCATION object:nil];
    
    if ([self isKindOfClass:[DiscoverViewController class]] || [self isKindOfClass:[DiscoverServiceViewController class]]) {
        [self addHorizontalPromotionBar];
        [self addDiscoverLocationView];
    }
    [self addGalleryView];
}

- (void)didUpdateLocation {
    self.shouldRefreshItems = ITEMS_GETNEW;
    [self refreshItemsIfNeed:nil];
}

- (void)addGalleryView {
    UIButton *btnGallery = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnGallery setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.galleryBarView addSubview:btnGallery];
    [btnGallery setTitle:NSLocalizedString(@"gallery", @"") forState:UIControlStateNormal];
    [btnGallery setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnGallery setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btnGallery addTarget:self action:@selector(handleBtnGallery) forControlEvents:UIControlEventTouchUpInside];
    [btnGallery setImage:[UIImage imageNamed:@"gallery_view_selected"] forState:UIControlStateSelected];
    [btnGallery setImage:[UIImage imageNamed:@"gallery_view_unselected"] forState:UIControlStateNormal];
    btnGallery.selected = YES;
    [btnGallery setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [btnGallery.titleLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
    self.btnGallery = btnGallery;
    [self.galleryBarView addLeadingConstraintForItem:btnGallery];
    [self.galleryBarView addTopConstraintForItem:btnGallery];
    [self.galleryBarView addBottomConstraintForItem:btnGallery];
    [self.galleryBarView addWidthConstraintForItem:btnGallery withMultiplier:0.5];
    
    UIButton *btnListView = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnListView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.galleryBarView addSubview:btnListView];
    [btnListView setTitle:NSLocalizedString(@"social_view", @"") forState:UIControlStateNormal];
    [btnListView setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnListView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btnListView addTarget:self action:@selector(handleBtnListView) forControlEvents:UIControlEventTouchUpInside];
    [btnListView setImage:[UIImage imageNamed:@"list_view_selected"] forState:UIControlStateSelected];
    [btnListView setImage:[UIImage imageNamed:@"list_view_unselected"] forState:UIControlStateNormal];
    [btnListView setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [btnListView.titleLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
    self.btnSocialView = btnListView;
    [self.galleryBarView addLeadingConstraintForItem:btnListView rightItem:btnGallery leading:0];
    [self.galleryBarView addTopConstraintForItem:btnListView];
    [self.galleryBarView addBottomConstraintForItem:btnListView];
    [self.galleryBarView addWidthConstraintForItem:btnListView withMultiplier:0.5];
    [self.galleryBarView addTrailingConstraintForItem:btnListView];
    
    [self.galleryBarView setBackgroundColor:GRAY_COLOR];
    [self.galleryView setBackgroundColor:GRAY_COLOR];
    self.galleryBarView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.galleryBarView.layer.shadowOpacity = 1;
    self.galleryBarView.layer.shadowOffset = CGSizeMake(self.galleryBarView.frame.size.width, -4);
    
}

- (void)addDiscoverLocationView {
    self.locationDiscoverView = [[LocationDiscoverView alloc] initWithBlock:^(LocationDiscoverView *locationView, NSString *title) {
        if ([title isEqualToString:CountrySelect]) {
            [self handleCountrySelect];
        } else if ([title isEqualToString:TurnOnLocationLabel]) {
            [self didTurnOnLocation];
        } else if ([title isEqualToString:SearchSelect]) {
            [self searchItems];
        }
    }];
    [self.locationView addSubview:self.locationDiscoverView];
    [Utils addFitConstraintToView:self.locationView subView:self.locationDiscoverView];
}

- (void)handleCountrySelect {
    CountriesViewController *vc = [[CountriesViewController alloc] init];
    vc.countries = [[[AppManager sharedInstance] getAddresses] getCountries];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleBtnGallery {
    [self.tableView setHidden:YES];
    [self.galleryView setHidden:NO];
    self.btnGallery.selected = YES;
    self.btnSocialView.selected = NO;
}

- (void)handleBtnListView {
    [self.tableView setHidden:NO];
    [self.galleryView setHidden:YES];
    self.btnGallery.selected = NO;
    self.btnSocialView.selected = YES;
}

- (void)addHorizontalPromotionBar {
    [self UpdateLocationBarHeight];
    HorizontalDiscoverBar *horizontalBar = [[HorizontalDiscoverBar alloc] initWithBlock:^(HorizontalDiscoverBar *horizontalBar, PromotionCriteria *selectedCriteria) {
        [self didSelectCriteria:selectedCriteria];
    }];
    [horizontalBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.horizontalBarContainer addSubview:horizontalBar];
    self.horizontalBar = horizontalBar;
    [self.horizontalBarContainer setBackgroundColor:PURPLE_COLOR];
    [self.horizontalBar setBackgroundColor:PURPLE_COLOR];
    __weak id weakRef = self;
    [self.horizontalBar setTurnOnLocationBlock:^(HorizontalDiscoverBar *horizontalBar) {
        [weakRef didTurnOnLocation];
    }];
    [Utils addFitConstraintToView:self.horizontalBarContainer subView:self.horizontalBar];
    [self.view bringSubviewToFront:self.horizontalBar];
}

- (void)UpdateLocationBarHeight {
    if (![[LocationManager sharedInstance] authorizationStatusEnable]) {
        self.lcHeightHorizontalBar.constant = HorizontalBarWithLocation;
    } else {
        self.lcHeightHorizontalBar.constant = HorizontalBarWithoutLocation;
    }
}

- (void)didTurnOnLocation {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)openAllDiaglog:(PromotionCriteria *)selectedCrit {
    DiscoverAllDiaglog *diaglog = [[DiscoverAllDiaglog alloc] initWithBlock:^(DiscoverAllDiaglog *moreDiaglog, NSString *title) {
        MenuViewController *menu = nil;
        if ([self.getMenuViewController isKindOfClass:[MenuViewController class]]) {
            menu = (MenuViewController *)self.getMenuViewController;
        }
        if ([title isEqualToString:NSLocalizedString(@"all_talents", @"")]) {
            if ([self isKindOfClass:[DiscoverViewController class]]) {
                // Open all talent in style screen
                [AppManager sharedInstance].currentCriteria = selectedCrit;
                [menu openDiscoverScreen:DISCOVER_SERVICES criteria:selectedCrit];
                return;
            }
        } else if ([title isEqualToString:NSLocalizedString(@"all_styles", @"")]) {
            if ([self isKindOfClass:[DiscoverServiceViewController class]]) {
                [AppManager sharedInstance].currentCriteria = selectedCrit;
                [menu openDiscoverScreen:DISCOVER criteria:selectedCrit];
                return;
            }
        }
        self.shouldRefreshItems = ITEMS_GETNEW;
        [self refreshItemsIfNeed:nil];
    }];
    [diaglog showInView:self.view];
}

- (void)reloadDataWithCriteria:(PromotionCriteria *)selectedCriteria {
    // Get news item with promotion type
    MenuViewController *menu = nil;
    if ([self.getMenuViewController isKindOfClass:[MenuViewController class]]) {
        menu = (MenuViewController *)self.getMenuViewController;
    }
    
    if (![Utils isNilOrNull:menu]) {
        if ([self isKindOfClass:[DiscoverServiceViewController class]]) {
            if ([selectedCriteria isCriteriaOfProductType]) {
                DLog(@"Select Product In Talent Screen");
                [AppManager sharedInstance].currentCriteria = selectedCriteria;
                [menu openDiscoverScreen:DISCOVER criteria:selectedCriteria];
                return;
            }
        } else if ([self isKindOfClass:[DiscoverViewController class]]) {
            if ([selectedCriteria isCriteriaOfTalentType]) {
                DLog(@"Select Talent In Product Screen");
                [AppManager sharedInstance].currentCriteria = selectedCriteria;
                [menu openDiscoverScreen:DISCOVER_SERVICES criteria:selectedCriteria];
                return;
            }
        }
    }
    self.shouldRefreshItems = ITEMS_GETNEW;
    [self refreshItemsIfNeed:nil];
}

- (void)didSelectCriteria:(PromotionCriteria *)selectedCriteria {
    DLog(@"Selected Crits:%@ : %@",selectedCriteria.getIdString, selectedCriteria.displayText);
    [AppManager sharedInstance].currentCriteria = nil;
    if (![[self.horizontalBar getCurrentSelectedCriteria] isEqual:selectedCriteria]) {
        // Select from the other screen
        // Should update horizontal bar again
        [self.horizontalBar setSelectItem:selectedCriteria];
    }
    BOOL isOpenFromAllDiaglog = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FromAllDiaglog"] boolValue];
    if ([selectedCriteria.promotionType isEqualToString:PROMOTION_TYPE_MORE]) {
        // Promotion Type More should open search screen
        [self openSearchDiaglog];
    } else if ([selectedCriteria.promotionType isEqualToString:PROMOTION_TYPE_ALL] && !isOpenFromAllDiaglog) {
        [self openAllDiaglog:selectedCriteria];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"FromAllDiaglog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"FromAllDiaglog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reloadDataWithCriteria:selectedCriteria];
    }
}

- (void)openSearchDiaglog {
    DiscoverMoreDiaglog *vc = [[DiscoverMoreDiaglog alloc] initWithBlock:^(DiscoverMoreDiaglog *moreDiaglog, NSString *title) {
        if ([title isEqualToString:@"People"]) {
            SellerNamesViewController *vc = [[SellerNamesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        SearchViewController *searchVC = [[SearchViewController alloc] init];
        if ([title isEqualToString:@"Talent"]) {
            searchVC.isService = YES;
        }
        [self.navigationController pushViewController:searchVC animated:YES];
    }];
    [vc showInView:self.view];
}

- (NSString *)handleGetCountryLogic {
    NSString *country = [[AppManager sharedInstance] getCountryFromCountrySelector];
    if ([[LocationManager sharedInstance] authorizationStatusEnable]) {
        country = [[LocationManager sharedInstance] getCurrentCountry];
    } else {
        [[EventManager shareInstance] fireEventWithType:ET_DISABLE_LOCATION result:nil channel:CHANNEL_UI];
        if ([[UserManager sharedInstance] isLogin]) {
            AccountModel *account = [[UserManager sharedInstance] getAccount];
            if (account.country.length > 0) {
                country = account.country;
            }
        } else {
            // Show view
            if (country.length == 0) { // Country Selector already there
                [[EventManager shareInstance] fireEventWithType:ET_SHOW_NO_LOCATION_VIEW result:nil channel:CHANNEL_UI];
            }
        }
    }
    return country;
}

- (CLLocation *)getCurrentLocation {
    if ([[LocationManager sharedInstance] authorizationStatusEnable]) {
        return [[LocationManager sharedInstance] getCurrentLocation];
    } else if ([[UserManager sharedInstance] isLogin]) {
        AccountModel *account = [[UserManager sharedInstance] getAccount];
        return [[CLLocation alloc] initWithLatitude:account.latitude longitude:account.longitude];
    }
    return nil;
}

- (void)dispatchChannelEvent:(Event *)aEvent {
    if (aEvent.eventType == ET_DISABLE_LOCATION) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self UpdateLocationBarHeight];
            [self.horizontalBar shouldHideLocationBar:NO];
        });
    } else if (aEvent.eventType == ET_DID_TURN_ON_LOCATION) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self UpdateLocationBarHeight];
            [self.horizontalBar shouldHideLocationBar:YES];
        });
    } else if (aEvent.eventType == ET_SHOW_NO_LOCATION_VIEW) {
        [self showNoLocationView:YES isNoResult:NO];
    }
}

- (void)showNoLocationView:(BOOL)shouldShow isNoResult:(BOOL)isNoResult{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationDiscoverView shouldShowNoResult:isNoResult];
        if (shouldShow) {
            [self.view bringSubviewToFront:self.locationView];
        } else {
            if ([self.btnGallery isSelected]) {
                [self.view bringSubviewToFront:self.galleryView];
            } else {
                [self.view bringSubviewToFront:self.tableView];
            }
        }
    });
}

- (void)searchItems {
    [self openSearchDiaglog];
}

- (void)addConstraintsForHorizontalBar {
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self.horizontalBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.horizontalBarContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.horizontalBarContainer addConstraint:lc];
    
    lc = [NSLayoutConstraint constraintWithItem:self.horizontalBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.horizontalBarContainer attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.horizontalBarContainer addConstraint:lc];
    
    lc = [NSLayoutConstraint constraintWithItem:self.horizontalBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.horizontalBarContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.horizontalBarContainer addConstraint:lc];
    
    lc = [NSLayoutConstraint constraintWithItem:self.horizontalBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.horizontalBarContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.horizontalBarContainer addConstraint:lc];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    __weak ItemsViewController *weakRef = self;
    [self.tableView addPullToRefreshWithActionHandler:^(void) {
        [weakRef.itemsThread cancel];
        weakRef.itemsThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:weakRef selector:@selector(executeDownloadItemAndInsertPositionTop:threadObj:) argument:@""];
    }
                                             position:SVPullToRefreshPositionTop];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^(void) {
        [weakRef.itemsThread cancel];
        weakRef.itemsThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:weakRef selector:@selector(executeDownloadItemAndInsertPositionBottom:threadObj:) argument:@""];
    }];
    
    [self.galleryView addPullToRefreshWithActionHandler:^(void) {
        [weakRef.itemsThread cancel];
        weakRef.itemsThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:weakRef selector:@selector(executeDownloadItemAndInsertPositionTop:threadObj:) argument:@""];
    }
                                             position:SVPullToRefreshPositionTop];
    
    [self.galleryView addInfiniteScrollingWithActionHandler:^(void) {
        [weakRef.itemsThread cancel];
        weakRef.itemsThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:weakRef selector:@selector(executeDownloadItemAndInsertPositionBottom:threadObj:) argument:@""];
    }];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (Response *)connectToServerToGetItems {
    [self handleGetCountryLogic];
    NSString *country = nil;
    BOOL isServiceScreen = [self isKindOfClass:[DiscoverServiceViewController class]] ? YES : NO;
    PromotionCriteria *criteria = [self.horizontalBar getCurrentSelectedCriteria];
    
    if ([criteria.promotionType isEqualToString:PROMOTION_TYPE_MORE]) {
        return nil;
    }
    
    if (![criteria.promotionType isEqualToString:PROMOTION_TYPE_ALL] && criteria) {
        // Query Item With Promotion Type != ALL
        
        // Check Location Promotion Type
        if ([criteria isLocationPromotionType]) {
            // Is Location Type has L prefix
            // Location Type will pass country param to server
            country = [self handleGetCountryLogic];
            CLLocation *location = [self getCurrentLocation];
            return [CloudManager getItemsWithLimitedCriteria:criteria isService:isServiceScreen country:country fromPage:self.downLoadingPage andPer:PER_COUNT radius:50 location:location];
        } else {
            // Not Location Type
            return [CloudManager getItemsWithCriteria:criteria isService:isServiceScreen country:country fromPage:self.downLoadingPage andPer:PER_COUNT];
        }
    } else {
        // Get Promotion Type ALL
        country = [self handleGetCountryLogic];
        return [CloudManager getItems:isServiceScreen country:country fromPage:self.downLoadingPage andPer:PER_COUNT];
    }
}

- (NSMutableArray *)filterItems:(NSMutableArray *)items {
    return items;
}

- (void)downloadLatestItemsCompleted:(BOOL)itemCount {
    
}

- (ItemModel *)getIemById:(NSNumber *)itemId {
    for (ItemModel *item in self.items) {
        if ([itemId isEqualToNumber:item.id]) {
            return item;
        }
    }
    return nil;
}

- (void)removeAnItemAndRefreshTableView:(ItemModel *)item {
    [self.items removeObject:item];
    [self reloadData];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GalleryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    cell.item = [self.items objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell configureCellForItem:cell.item];
    if (cell.item.cellHeight == 0) {
        cell.imItem.categoryDelegate = self;
        cell.imItem.tag  = indexPath.row;
    } else {
        cell.lcHeightImItem.constant = cell.item.cellHeight - 00;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        ItemModel *item = [self.items objectAtIndex:indexPath.row];
        [item loadFirstImage];
    }
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)cbImageView:(UIImageView *)cbImageView didFinishDownloadingImage:(UIImage *)aDownloadedImage downloadFailUrl:(NSString *)url {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:cbImageView.tag inSection:0];
    cbImageView.categoryDelegate = nil;
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GalleryCollectionViewCell *cell = (GalleryCollectionViewCell *)[self.galleryView cellForItemAtIndexPath:indexPath];
//            cell.lcHeightImItem.constant = [self getHeightForImage:aDownloadedImage cellSize:cbImageView.frame.size];
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            ItemModel *item = [self.items objectAtIndex:indexPath.row];
            item.cellHeight = [self getHeightForImage:aDownloadedImage cellSize:cbImageView.frame.size] + 60;
            DLog(@"Cell Height:%f - %@", item.cellHeight, cell.item.getLocation);
            if (!item.imageLoaded) {
                if (indexPath.row == 1) {
                    [self.galleryView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
                    return ;
                }
                [self.galleryView reloadItemsAtIndexPaths:@[indexPath]];
                item.imageLoaded = YES;
            }
        });
    }
}

- (CGFloat)getHeightForImage:(UIImage *)image cellSize:(CGSize)size {
    CGFloat cellHeight = size.width * image.size.height / image.size.width;
    DLog(@"CurrentImage:%@ - Height:%f", image, cellHeight);
    return cellHeight;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    GalleryCollectionViewCell *sizingCell = [[NSBundle mainBundle] loadNibNamed:@"GalleryCollectionViewCell" owner:self options:nil][0];
    ItemModel *item = [self.items objectAtIndex:indexPath.row];
    [item loadFirstImage];
    CGFloat maxWidth = self.view.frame.size.width / 2 - 2;
    if (item.cachedFirstImage) {
        CGFloat height = maxWidth * item.cachedFirstImage.size.height / item.cachedFirstImage.size.width + 60;
        item.cellHeight = height;
        item.imageLoaded = YES;
        return CGSizeMake(maxWidth, height);
    } else {
        DLog(@"No cache image");
    }
//    [sizingCell configureCellForItem:item];
    if (item.cellHeight > 0) {
        return CGSizeMake(maxWidth, item.cellHeight);
    }
    return CGSizeMake(maxWidth, 200);
}
#pragma mark - GallerViewCollectionViewCellDelegate
- (void)didOpenSellerInfo:(ItemModel *)item {
    [self openSellerProfilePage:item sender:self];
}

- (void)didOpenItem:(ItemModel *)item sender:(id)sender {
    MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
    GalleryCollectionViewCell *cell = (GalleryCollectionViewCell *)sender;
    vc.avatarImage = [cell getAvatarImage];
    vc.firstImage = [cell getFirstImage];
    vc.itemModel = item;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Private Method
- (void)sendActionToServerIfNeed:(NSDictionary *)notifUserInfo {
    if ([[UserManager sharedInstance] isLogin]) {
        REQUIRED_LOGIN_ACTION action = [[notifUserInfo objectForKey:USERINFO_ACTION_KEY] intValue];
        ItemModel *itemModel = [notifUserInfo objectForKey:USERINFO_ITEM_KEY];
        if (itemModel == nil && action != ACTION_POST_SOMETHING)
            return;
        
        switch (action) {
            case ACTION_LIKE: {
                if (!itemModel.liked) {
                    [self likeItem:itemModel];
                }
            }
                break;
            case ACTION_WISHLIST: {
                if (!itemModel.in_wish_list) {
                    [self wishlistItem:itemModel];
                }
            }
                break;
            case ACTION_FLAG: {
                if (!itemModel.flagged) {
                    [self flagItem:itemModel];
                }
            }
                break;
            case ACTION_CONTACT_SELLER: {
                [self contactSellerToBuyItem:itemModel];
            }
                break;
            case ACTION_POST_SOMETHING: {
                [self openPostSomethingPage];
            }
                break;
            default:
                break;
        }
    }
}

- (void)refreshItemsIfNeed:(NSDictionary *)userInfo {
    if (userInfo == nil) {
        userInfo = [NSDictionary dictionary];
    }
    self.runningThread = nil;
    self.itemsThread = nil;
    if (self.shouldRefreshItems == ITEMS_GETNEW) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadItems:threadObj:) argument:@""];
    }
    else if (self.shouldRefreshItems == ITEMS_UPDATESTATUS) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateItemsStatus:threadObj:) argument:userInfo];
    }
    else if (self.shouldRefreshItems == ITEMS_RESETSTATUS) {
        for (ItemModel *itemModel in self.items) {
            [itemModel resetStatus];
        }
    }
    
    if (self.shouldRefreshItems != ITEMS_DONOTHING) {
        [self reloadData];
    }
    self.shouldRefreshItems = ITEMS_DONOTHING;
}

- (void)contactSellerToBuyItem:(ItemModel *)itemModel {
    if ([[UserManager sharedInstance] isLogin]) {
        ContactSellerViewController *vc = [[ContactSellerViewController alloc] init];
        vc.userId = [itemModel.sellerModel getIdString];
        vc.fullName = [itemModel.sellerModel getDisplayName];
        vc.itemModel = itemModel;
        if ([itemModel isService]) {
            [vc setDefaultMessage:NSLocalizedString(@"message_interested_in_service", @"")];
        }
        else {
            [vc setDefaultMessage:NSLocalizedString(@"message_to_buy_item", @"")];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:itemModel, USERINFO_ITEM_KEY, @(ACTION_CONTACT_SELLER), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)openPostSomethingPage {
    if ([[UserManager sharedInstance] isLogin]) {
        MenuViewController *menuVC = (MenuViewController *)[self getMenuViewController];
        [menuVC openPostSomethingPage];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_POST_SOMETHING), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

#pragma mark - Notification Center
- (void)updateFollowingOfItems:(NSNotification *)noti {
    NSDictionary *dict = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    NSString *objId = [[dict objectForKey:@"id"] description];
    for (ItemModel *item in self.items) {
        if ([[item.sellerModel getIdString] isEqualToString:objId]) {
            [item.sellerModel updateWithDictionary:dict];
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)updateRatingOfItems:(NSNotification *)noti {
    NSDictionary *dict = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    NSString *objId = [[dict objectForKey:@"id"] description];
    for (ItemModel *item in self.items) {
        if ([[item.sellerModel getIdString] isEqualToString:objId]) {
            [item.sellerModel updateWithDictionary:dict];
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)updateWishlistOfItems:(NSNotification *)noti {
    NSDictionary *dict = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    NSString *objId = [[dict objectForKey:@"id"] description];
    for (ItemModel *item in self.items) {
        if ([[item getIdString] isEqualToString:objId]) {
            [item updateWithDictionary:dict];
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)updateFlagingOfItems:(NSNotification *)noti {
    NSString *objId = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    for (ItemModel *item in self.items) {
        if ([[item getIdString] isEqualToString:objId]) {
            item.flagged = YES;
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)updateLikingOfItems:(NSNotification *)noti {
    NSDictionary *dict = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    NSString *objId = [[dict objectForKey:@"id"] description];
    for (ItemModel *item in self.items) {
        if ([[item getIdString] isEqualToString:objId]) {
            [item updateWithDictionary:dict];
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)updateItem:(NSNotification *)noti {
    NSDictionary *dict = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    NSString *objId = [[dict objectForKey:@"id"] description];
    for (ItemModel *item in self.items) {
        if ([[item getIdString] isEqualToString:objId]) {
            [item updateWithDictionary:dict];
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)deleteItem:(NSNotification *)noti {
    NSString *objId = [noti.userInfo objectForKey:NOTIFICATION_USERINFO_KEY];
    for (ItemModel *item in self.items) {
        if ([[item getIdString] isEqualToString:objId]) {
            [self.items removeObject:item];
            self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
            break;
        }
    }
    [self refreshItemsIfNeed:nil];
}

- (void)updateCommentOfItems:(NSNotification *)noti {
    self.shouldRefreshItems = ITEMS_RELOAD_SCREEN;
    [self refreshItemsIfNeed:nil];
}

- (void)willLogInNotification:(NSNotification *)noti {
    if ([noti.userInfo objectForKey:USERINFO_ACTION_KEY]) {
        self.shouldRefreshItems = ITEMS_UPDATESTATUS;
    }
}

- (void)didLogInNotification:(NSNotification *)noti {
    [self showNoLocationView:NO isNoResult:NO];
    [self refreshItemsIfNeed:noti.userInfo];
}

- (void)didLogOutNotification:(NSNotification *)noti {
    self.shouldRefreshItems = ITEMS_RESETSTATUS;
    [self refreshItemsIfNeed:noti.userInfo];
}

- (NSArray *)getAllItems {
    return self.items;
}

- (void)reloadData {
    [self.galleryView reloadData];
    [self.tableView reloadData];
}

#pragma mark - CountriesViewControllerDelegate
- (void)searchCountryResult:(NSString *)country {
    [[LocationManager sharedInstance] setCurrentCountry:country];
    [[AppManager sharedInstance] setCountryFromCountrySelector:country];
    self.shouldRefreshItems = ITEMS_GETNEW;
    [self refreshItemsIfNeed:nil];
    [self showNoLocationView:NO isNoResult:NO];
}

#pragma mark - execute
- (void)executeLikeItem:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager likeItem:[item getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [item updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIKED_ITEM_NOTIFICATION object:nil userInfo:userInfo];
            [self reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeGetPromotionCriteria:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getPromotionCriteria];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        if (self.promotionCriterias.count > 0) {
            [self.promotionCriterias removeAllObjects];
        }
        for (NSDictionary *dict in response.getJsonObject) {
            PromotionCriteria *proCrit = [[PromotionCriteria alloc] initWithDictionary:dict];
            [self.promotionCriterias addObject:proCrit];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.horizontalBar setPromotionList:[[AppManager sharedInstance] getPromotionCriteriaList:self.promotionCriterias]];
        });
        
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeWishlistItem:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager wishlishItem:[item getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [item updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_WISHLISTED_ITEM_NOTIFICATION object:nil userInfo:userInfo];
            [self reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeMarkFlagItem:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager markFlagOnItem:item];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        item.flagged = YES;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : [item getIdString]};
            [[NSNotificationCenter defaultCenter] postNotificationName:FLAG_ITEM_NOTIFICATION object:nil userInfo:userInfo];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeUpdateFollowThisSeller:(SellerModel *)seller threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager updateFollowASeller:[seller getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *dict = response.getJsonObject;
            for (ItemModel *item in self.items) {
                if ([item.sellerModel.getIdString isEqualToString:[seller getIdString]]) {
                    [seller updateWithDictionary:dict];
                    [item.sellerModel updateWithDictionary:dict];
                }
            }
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FOLLOWED_USER_NOTIFICATION object:nil userInfo:userInfo];
            [self reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)downloadLastestItems:(BOOL)shouldShowErrorAlert threadObj:(id<OperationProtocol>)threadObj {
    self.downLoadingPage = 1;
    Response *response = [self connectToServerToGetItems];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response shouldShowAlert:shouldShowErrorAlert]) {
        NSArray *array = response.getJsonObject;
        if (array.count == 0) { // Show no results view
            [self showNoLocationView:YES isNoResult:YES];
        } else {
            if ([[LocationManager sharedInstance] authorizationStatusEnable] || [[UserManager sharedInstance] isLogin]) {
                [self showNoLocationView:NO isNoResult:NO];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self downloadLatestItemsCompleted:array.count];
        });
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            ItemModel *item = [[ItemModel alloc] initWithDictionary:dict];
            if (item) {
                [results addObject:item];
            }
        }
        // increasing page for next request
        self.downLoadingPage++;
        NSMutableArray *filteredItems = [self filterItems:results];
        self.items = [NSMutableArray arrayWithArray:filteredItems];
        for (ItemModel *anItem in self.items) {
            [anItem downloadReparatoryImages];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_COMPLETED_NOTIFICATION object:nil];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self downloadLatestItemsCompleted:0];
        });
    }
}

- (void)executeDownloadItems:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    [self downloadLastestItems:YES threadObj:threadObj];
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadItemAndInsertPositionTop:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self downloadLastestItems:NO threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.pullToRefreshView stopAnimating];
        [self.galleryView.pullToRefreshView stopAnimating];
    });
    [threadObj releaseOperation];
}

- (void)executeDownloadItemAndInsertPositionBottom:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [self connectToServerToGetItems];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response shouldShowAlert:NO]) {
        NSArray *array = response.getJsonObject;
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            ItemModel *item = [[ItemModel alloc] initWithDictionary:dict];
            if (item) {
                [results addObject:item];
                [item downloadReparatoryImages];
            }
        }
        
        if (results.count > 0) {
            // increasing page for next request
            self.downLoadingPage++;
            NSMutableArray *filteredItems = [self filterItems:results];
            [self.items addObjectsFromArray:filteredItems];
            for (ItemModel *anItem in filteredItems) {
                [anItem downloadReparatoryImages];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self reloadData];
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.galleryView.infiniteScrollingView stopAnimating];
    });
    [threadObj releaseOperation];
}

- (void)executeUpdateItemsStatus:(NSDictionary *)notifUserInfo threadObj:(id<OperationProtocol>)threadObj {
    BaseViewController *topVc = (BaseViewController *)self.navigationController.topViewController;
    [topVc startSpinnerWithWaitingText];
    NSMutableString *itemIds = [[NSMutableString alloc] init];
    for (ItemModel *item in self.items) {
        [itemIds appendFormat:@"%@,", [item getIdString]];
    }
    Response *response = [CloudManager getItemsByIds:itemIds];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSArray *array = response.getJsonObject;
        for (NSDictionary *dict in array) {
            for (ItemModel *itemModel in self.items) {
                if ([itemModel isEqualToDictionaryOfItem:dict]) {
                    [itemModel updateWithDictionary:dict];
                    break;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (topVc == self) {
                [self sendActionToServerIfNeed:notifUserInfo];
            }
            else {
                [topVc.view setNeedsLayout];
                [topVc.view layoutIfNeeded];
                if ([topVc isKindOfClass:[SellerProfileViewController class]]) {
                    [(SellerProfileViewController *)topVc sendActionToServerIfNeed:notifUserInfo];
                }
                if ([topVc isKindOfClass:[MoreInfoViewController class]]) {
                    [(MoreInfoViewController *)topVc sendActionToServerIfNeed:notifUserInfo];
                }
            }
            [self reloadData];
        });
    }
    [topVc stopSpinner];
    [threadObj releaseOperation];
}

#pragma mark - ItemTableViewCellDelegate
- (void)seeMorePost:(SellerModel *)seller {
    ListedItemsViewController *vc = [[ListedItemsViewController alloc] init];
    vc.userModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openMoreInfoPage:(ItemModel *)item sender:(id)sender {
    MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
    ItemTableViewCell *cell = sender;
    vc.avatarImage = [cell getAvatar];
    vc.firstImage = [cell getFirstImage];
    vc.itemModel = item;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openCommentPage:(ItemModel *)item sender:(id)sender {
    MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
    ItemTableViewCell *cell = sender;
    vc.avatarImage = [cell getAvatar];
    vc.firstImage = [cell getFirstImage];
    vc.itemModel = item;
    vc.shouldAutoLoadComments = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openCommentsPage:(ItemModel *)item sender:(id)sender {
    [self openCommentPage:item sender:(id)sender];
}

- (void)buyNow:(ItemModel *)item sender:(id)sender {
    [self contactSellerToBuyItem:item];
}

- (void)openSellerProfilePage:(ItemModel *)item sender:(id)sender {
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    vc.sellerModel = item.sellerModel;
    vc.itemModel = item;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)openLikerProfilePage:(SellerModel *)seller {
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    vc.sellerModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)likeItem:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeLikeItem:threadObj:) argument:item];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:item, USERINFO_ITEM_KEY, @(ACTION_LIKE), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)wishlistItem:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeWishlistItem:threadObj:) argument:item];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:item, USERINFO_ITEM_KEY, @(ACTION_WISHLIST), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)flagItem:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeMarkFlagItem:threadObj:) argument:item];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:item, USERINFO_ITEM_KEY, @(ACTION_FLAG), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)updateSellerFollowStatus:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateFollowThisSeller:threadObj:) argument:item.sellerModel];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:item, USERINFO_ITEM_KEY, @(ACTION_WISHLIST), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)shareItem:(ItemModel *)item {
    [[AppManager sharedInstance] shareItem:item viewController:self];
}

- (void)openLikersPage:(ItemModel *)item {
    LikersViewController *vc = [[LikersViewController alloc] init];
    vc.itemModel = item;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openFollowersPage:(SellerModel *)seller {
    FollowersViewController *vc = [[FollowersViewController alloc] init];
    vc.userModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)markInAppropriate:(ItemModel *)item {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"alert_mark_inappropriate", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"alert_button_yes", @""), nil];
    alertView.context = item;
    alertView.tag = INAPPROPRIATE_ALERT_TAG;
    [alertView show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self.tableView setBackgroundColor:(self.items.count == 0) ? [UIColor whiteColor] : UIColorFromRGB(0xb5b4b4)];
    [self.tableView.infiniteScrollingView setHidden:(self.items.count == 0)];
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemCellIdentifier";
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([ItemTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        cell.delegate = self;
        cell.scvGallery.aDelegate = self;
    }
    ItemModel *itemModel = [self.items objectAtIndex:indexPath.row];
    cell.itemModel = itemModel;
    itemModel.aDelegate = self;
    if (itemModel.sellerModel.avatar.length == 0) {
        [cell setAvatar:nil];
    }
    else {
        [itemModel loadAvatar];
    }
    [itemModel loadFirstImage];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = (indexPath.row < self.items.count) ? indexPath.row : 0;
    ItemModel *itemModel = [self.items objectAtIndex:index];// sometimes crashed in here if has no row above, fix later
    if (!self.offScreenCell) {
        self.offScreenCell = [[[UINib nibWithNibName:NSStringFromClass([ItemTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    itemModel = [self.items objectAtIndex:indexPath.row];
    self.offScreenCell.itemModel = itemModel;
    [self.offScreenCell setItemModelToCalcHeightOfCell:itemModel];
    
    [self.offScreenCell setNeedsUpdateConstraints];
    [self.offScreenCell updateConstraintsIfNeeded];
    self.offScreenCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.offScreenCell.bounds));
    [self.offScreenCell setNeedsLayout];
    [self.offScreenCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [self.offScreenCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return [self.offScreenCell cellHeight];
}

#pragma mark - ItemModelDelegate
- (void)didFinishLoadingAvatar:(UIImage *)image sender:(id)sender {
    ItemModel *anItem = sender;
    for (ItemTableViewCell *cell in self.tableView.visibleCells) {
        if (cell.itemModel == anItem) {
            [cell setAvatar:image];
            break;
        }
    }
}

- (void)didFinishLoadingFirstImage:(UIImage *)image sender:(id)sender {
    ItemModel *anItem = sender;
    for (ItemTableViewCell *cell in self.tableView.visibleCells) {
        if (cell.itemModel == anItem) {
            [cell setFirstImage:image];
            break;
        }
    }
}

- (void)didHaveErrorWhileLoadingImaeUrl:(NSString *)url sender:(id)sender {
    DLog(@"Download image error: %@", url);
}

#pragma mark - ImagesScrollViewDelegate
- (void)popupZoomingImages:(NSArray *)images currentIndex:(NSInteger)index {
    ImagePopupViewController *vc = [[ImagePopupViewController alloc] init];
    vc.images = images;
    vc.currentIndex = index;
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == INAPPROPRIATE_ALERT_TAG) {
        if (buttonIndex == 1) {
            [self flagItem:alertView.context];
        }
    }
}
@end
