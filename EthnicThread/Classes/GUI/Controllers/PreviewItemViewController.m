//
//  PreviewItemViewController.m
//  EthnicThread
//
//  Created by Katori on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "PreviewItemViewController.h"
#import "ItemView.h"
#import "LocationView.h"
#import "AnimatedTransitioning.h"
#import "EditItemDelegate.h"
#import "PreviewTagsView.h"
#import "ReadMoreViewController.h"
#import "AddItemFinishViewController.h"
#import "ImagePopupViewController.h"
#import "AddItemRequitedViewController.h"
#import "AddItemOptionalViewController.h"
#import "SellerProfileViewController.h"

@interface PreviewItemViewController () <SupViewOfMoreInfoDelegate, UIViewControllerTransitioningDelegate, ImagesScrollViewDelegate, EditItemDelegate, SlideNavigationControllerDelegate>
@property (nonatomic, strong) IBOutlet UIScrollView         *sclview;
@property (nonatomic, strong) UIView                        *vContent;
@property (nonatomic, assign) IBOutlet UIButton             *btnPostItem;

@property (nonatomic, strong) ItemView                      *itemView;
@property (nonatomic, strong) LocationView                  *vStoreLocation;
@property (nonatomic, assign) BOOL                          isEditting;
@end

@implementation PreviewItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ItemModel *itemModel = [self.createdItem generateItemModel];
     [self setNavigationBarTitle:itemModel.name andTextColor:BLACK_COLOR_TEXT];
    self.itemView.itemModel = itemModel;
    [self.itemView updateImages:self.createdItem.images];
    [self.itemView setAvatar:nil];
    [self.vStoreLocation displayLocationWithCoordinate:CLLocationCoordinate2DMake(itemModel.latitude, itemModel.longitude)
                                            andAddress:[itemModel getLocation]];
    [self.itemView updateContraintAndRenderScreenIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    
    if (self.isEditting) {
        [self setLeftNavigationItem:@""
                       andTextColor:nil
                     andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                           andFrame:CGRectMake(0, 0, 40, 35)];
    }
    else {
        [self setLeftNavigationItem:@""
                       andTextColor:nil
                     andButtonImage:[UIImage imageNamed:@"purple_menu"]
                           andFrame:CGRectMake(0, 0, 40, 35)];
    }
    
    [self setRightNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"edit_avatar_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    
    NSLayoutConstraint *lc;
    self.vContent = [[UIView alloc] initWithFrame:CGRectZero];
    
    //add item view
    self.itemView = [[[UINib nibWithNibName:NSStringFromClass([ItemView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.itemView.delegate = self;
    self.itemView.editDelegate = self;
    self.itemView.scvGallery.aDelegate = self;
    self.itemView.allowEdit = YES;
    [self.itemView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vContent addSubview:self.itemView];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    
    //location view
    self.vStoreLocation = [[[UINib nibWithNibName:NSStringFromClass([LocationView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.vStoreLocation.allowEdit = YES;
    self.vStoreLocation.editDelegate = self;
    [self.vStoreLocation setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vContent addSubview:self.vStoreLocation];
    lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.itemView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20];
    [self.vContent addConstraint:lc];
    
    ////////
    //add main content view to scrollview
    [self.vContent setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sclview addSubview:self.vContent];
    
    lc = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.sclview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.sclview addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sclview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.sclview addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.sclview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.sclview addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.sclview attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.sclview addConstraint:lc];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    lc = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenWidth];
    [self.sclview addConstraint:lc];
    [self.sclview setNeedsLayout];
    [self.sclview layoutIfNeeded];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    if (self.isEditting) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self handleTouchToMainMenuButton];
    }
}

- (void)handlerRightNavigationItem:(id)sender {
    [self editRequitedFields];
}

- (IBAction)handlePostButton:(id)sender {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executePostAnItem:threadObj:) argument:@""];
}

- (void)setCreatedItem:(CreativeItemModel *)createdItem {
    _createdItem = createdItem;
    self.isEditting = [self.createdItem isKindOfClass:[UpdateItemModel class]];
}

#pragma mark - Private Method
- (void)executePostAnItem:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    if (self.isEditting) {
        // update item
        Response *response = [CloudManager updateItem:(UpdateItemModel *)self.createdItem];
        if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
            NSDictionary *dict = response.getJsonObject;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_ITEM_NOTIFICATION object:nil userInfo:userInfo];
                [[CachedManager sharedInstance] removeAllCachedTempImages];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }
    else {
        // add new item
        Response *response = [CloudManager addNewItem:self.createdItem];
        if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSDictionary *dict = response.getJsonObject;
                [[CachedManager sharedInstance] removeAllCachedTempImages];
                AddItemFinishViewController *vc = [[AddItemFinishViewController alloc] init];
                vc.itemId = [[dict objectForKey:@"id"] description];
                [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                                      withSlideOutAnimation:NO
                                                                              andCompletion:nil];
            });
        }
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)handleEditPurchasesButton:(id)sender {
    [self editRequitedFields];
}

- (void)handleEditTagsButton:(id)sender {
    [self editRequitedFields];
}

#pragma mark - SupViewOfMoreInfoDelegate
- (void)openFullDescription:(NSString *)title andDescription:(NSString *)desc {
    ReadMoreViewController *vc = [[ReadMoreViewController alloc] init];
    vc.pageTitle = title;
    vc.fullText = desc;
    vc.transitioningDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.view.frame = self.view.frame;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)openSellerProfilePage:(SellerModel *)seller {
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    vc.sellerModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ImagesScrollViewDelegate
- (void)popupZoomingImages:(NSArray *)images currentIndex:(NSInteger)index {
    ImagePopupViewController *vc = [[ImagePopupViewController alloc] init];
    vc.images = images;
    vc.currentIndex = index;
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return !self.isEditting;
}

#pragma mark - EditItemDelegate
- (void)editRequitedFields {
    AddItemRequitedViewController *vc = [[AddItemRequitedViewController alloc] init];
    vc.createdItem = self.createdItem;
    vc.createdItem.isEdit = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editOptionalFields {
    AddItemOptionalViewController *vc = [[AddItemOptionalViewController alloc] init];
    vc.createdItem = self.createdItem;
    vc.createdItem.isEdit = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
