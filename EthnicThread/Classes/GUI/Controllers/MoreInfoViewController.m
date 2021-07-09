//
//  MoreInfoViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/11/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "MoreInfoViewController.h"
#import "ReadMoreViewController.h"
#import "ItemView.h"
#import "LocationView.h"
#import "CommentsView.h"
#import "SellerProfileViewController.h"
#import "MenuViewController.h"
#import "AnimatedTransitioning.h"
#import "ContactSellerViewController.h"
#import "InputMessageView.h"
#import "LikersViewController.h"
#import "ImagePopupViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIAlertView+Custom.h"
#import "CustomIOS7AlertView.h"

#define NUMBER_OF_COMMENT_PER_PAGE     5

@interface MoreInfoViewController () <SupViewOfMoreInfoDelegate, UIViewControllerTransitioningDelegate, UIScrollViewDelegate, CommentsViewDelegate, ImagesScrollViewDelegate, UIAlertViewDelegate> {
    BOOL    inputViewIsVisible;
}
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHeightContentView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcWidthContentView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHeightBuyButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHeightInputView;

@property (nonatomic, assign) IBOutlet InputMessageView     *inputMessageView;
@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView         *sclKeyboardAvoiding;
@property (nonatomic, strong) IBOutlet UIScrollView         *sclview;
@property (nonatomic, strong) UIView                        *vContent;
@property (nonatomic, assign) IBOutlet UIButton             *btnBuyThisItem;

@property (nonatomic, strong) ItemView                      *itemView;
@property (nonatomic, strong) LocationView                  *vStoreLocation;
@property (nonatomic, strong) CommentsView                  *commentsView;
@property (nonatomic, assign) ItemModel                     *itemNeedUpdateAfterLogedIn;
@property (nonatomic, assign) id<OperationProtocol>         runningThread;
@property (nonatomic, assign) id<OperationProtocol>         commentingThread;
@property (nonatomic, assign) NSInteger                     downloadedPage;
@property (nonatomic, strong) NSMutableArray                *comments;

- (IBAction)handlerBuyThisItemButton:(id)sender;
@end

@implementation MoreInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.downloadedPage = 1;
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:self.itemModel.name andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
             andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    if (self.shouldAutoLoadComments) {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        [self performSelector:@selector(enableBackButton) withObject:nil afterDelay:2.0];
    }
    
    self.inputMessageView.lcHeight = self.lcHeightInputView;
    [self.inputMessageView.btnSend addTarget:self action:@selector(handleSendCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    self.inputMessageView.textView.placeholder = NSLocalizedString(@"type_a_comment", @"");
    inputViewIsVisible = NO;
    
    [self.sclview setScrollEnabled:YES];
    self.sclview.delegate = self;
    NSLayoutConstraint *lc;
    self.vContent = [[UIView alloc] initWithFrame:CGRectZero];
    
    //add item view
    self.itemView = [[[UINib nibWithNibName:NSStringFromClass([ItemView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.itemView.vContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCommentKeyboard:)]];
    [self.itemView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.itemView.delegate = self;
    self.itemView.scvGallery.aDelegate = self;
    self.itemView.itemModel = self.itemModel;
    [self.itemView setFirstImage:self.firstImage];
    [self.itemView setAvatar:self.avatarImage];
    [self.vContent addSubview:self.itemView];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    
    UIView *beforeView = self.itemView;
    if ([self.itemModel getLocation].length > 0) {
        //location view
        self.vStoreLocation = [[[UINib nibWithNibName:NSStringFromClass([LocationView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [self.vStoreLocation displayLocationWithCoordinate:CLLocationCoordinate2DMake(self.itemModel.latitude, self.itemModel.longitude)
                                                andAddress:[self.itemModel getLocation]];
        [self.vStoreLocation addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCommentKeyboard:)]];
        [self.vStoreLocation setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.vContent addSubview:self.vStoreLocation];
        lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        [self.vContent addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [self.vContent addConstraint:lc];
        lc = [NSLayoutConstraint constraintWithItem:self.vStoreLocation attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.itemView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.vContent addConstraint:lc];
        beforeView = self.vStoreLocation;
    }
    
    //user reviews
    self.commentsView = [[[UINib nibWithNibName:NSStringFromClass([CommentsView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.commentsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCommentKeyboard:)]];
    self.commentsView.delegate = self;
    self.commentsView.allowDeleteAnyComment = [self.itemModel.sellerModel isMe];
    self.commentsView.lblNumberOfComment.text = [self.itemModel getNumberOfCommentsText];
    [self.commentsView stopAnimating:self.comments.count >= self.itemModel.total_comments];
    [self.commentsView.btnLoadMore setTitle:NSLocalizedString(@"view_previous_comments", @"") forState:UIControlStateNormal];
    [self.commentsView.btnLoadMore addTarget:self action:@selector(handleLoadOldCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vContent addSubview:self.commentsView];
    lc = [NSLayoutConstraint constraintWithItem:self.commentsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:beforeView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.commentsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.commentsView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.commentsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    
    
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
    lc = [NSLayoutConstraint constraintWithItem:self.vContent attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.width];
    [self.vContent addConstraint:lc];
}

- (void)updateViewConstraints {
    if ([self.itemModel isMine]) {
        self.lcHeightBuyButton.constant = 0;
        [self.btnBuyThisItem setHidden:YES];
    }
    else {
        self.lcHeightBuyButton.constant = 40;
        [self.btnBuyThisItem setHidden:NO];
    }
    self.lcWidthContentView.constant = [UIScreen mainScreen].bounds.size.width;
    self.lcHeightContentView.constant = [UIScreen mainScreen].bounds.size.height - (self.lcTop.constant + self.lcHeightBuyButton.constant) + self.lcHeightInputView.constant;
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.shouldAutoLoadComments) {
        [self scrollToBottom];
    }
}

- (void)scrollToBottom {
    CGRect rect = self.sclview.frame;
    rect.origin.y = self.sclview.contentSize.height - self.sclview.frame.size.height;
    [self.sclview scrollRectToVisible:rect animated:YES];
}

- (void)enableBackButton {
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

- (void)sendActionToServerIfNeed:(NSDictionary *)notifUserInfo {
    if ([[UserManager sharedInstance] isLogin]) {
        REQUIRED_LOGIN_ACTION action = [[notifUserInfo objectForKey:USERINFO_ACTION_KEY] intValue];
        switch (action) {
            case ACTION_LIKE: {
                if (!self.itemModel.liked) {
                    [self likeItem:self.itemModel];
                }
            }
                break;
            case ACTION_WISHLIST: {
                if (!self.itemModel.in_wish_list) {
                    [self wishlistItem:self.itemModel];
                }
            }
                break;
            case ACTION_FLAG: {
                if (!self.itemModel.flagged) {
                    [self flagItem:self.itemModel];
                }
            }
                break;
            case ACTION_COMMENT_ITEM: {
                [self handleSendCommentButton:self.inputMessageView.btnSend];
            }
                break;
            case ACTION_CONTACT_SELLER: {
                [self contactSellerToBuyItem:self.itemModel.sellerModel];
            }
                break;
            default:
                break;
        }
    }
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleLoadOldCommentButton:(id)sender {
    self.shouldAutoLoadComments = NO;
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadComments:threadObj:) argument:@(NO)];
}

- (void)handleSendCommentButton:(id)sender {
    if ([self.commentingThread isReady])
        return;
    NSString *comment = [self.inputMessageView.textView.text trimText];
    comment = [Utils convertEmojiToUnicode:comment];
    if (comment.length > 0) {
        if ([[UserManager sharedInstance] isLogin]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:comment forKey:@"comment"];
            self.commentingThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeSendComment:threadObj:) argument:dict];
        }
        else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_COMMENT_ITEM), USERINFO_ACTION_KEY, nil];
            [self showAlertToRequireLogin:userInfo];
        }
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_sorry", @"") message:NSLocalizedString(@"alert_please_enter_your_comment", @"")];
    }
}

- (void)dismissCommentKeyboard:(UIGestureRecognizer *)recognizer {
    [self.inputMessageView.textView resignFirstResponder];
}

- (void)contactSellerToBuyItem:(SellerModel *)seller {
    if ([[UserManager sharedInstance] isLogin]) {
        ContactSellerViewController *vc = [[ContactSellerViewController alloc] init];
        vc.userId = [self.itemModel.sellerModel getIdString];
        vc.fullName = [self.itemModel.sellerModel getDisplayName];
        vc.itemModel = self.itemModel;
        if ([self.itemModel isService]) {
            [vc setDefaultMessage:NSLocalizedString(@"message_interested_in_service", @"")];
        }
        else {
            [vc setDefaultMessage:NSLocalizedString(@"message_to_buy_item", @"")];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_CONTACT_SELLER), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

#pragma mark - Notification Center
- (IBAction)handlerBuyThisItemButton:(id)sender {
    [self contactSellerToBuyItem:self.itemModel.sellerModel];
}

#pragma mark - CommentsViewDelegate
- (void)openCommenter:(SellerModel *)commenter {
    [self.inputMessageView.textView resignFirstResponder];
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetCommenterInfo:threadObj:) argument:commenter.getIdString];
}

- (void)didSelectRowOfComment:(CommentModel *)comment {
    [self.inputMessageView.textView resignFirstResponder];
}

- (void)editComment:(CommentModel *)comment {
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 150)];
    ETPlaceHolderTextView *textView = [[ETPlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 10, 250, 130)];
    textView.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
    textView.layer.borderWidth = 1;
    [textView setFont:[UIFont systemFontOfSize:MEDIUM_FONT_SIZE]];
    [textView setTextColor:BLACK_COLOR_TEXT];
    textView.placeholder = NSLocalizedString(@"type_a_comment", @"");
    textView.text = comment.comment;
    [demoView addSubview:textView];
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    [alertView setContainerView:demoView];
    [alertView setButtonTitles:@[NSLocalizedString(@"alert_button_cancel", @""), NSLocalizedString(@"alert_button_save", @"")]];
    __block MoreInfoViewController *me = self;
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1) {
            NSString *text = [textView.text trimText];
            if (text.length > 0) {
                NSDictionary *param = [NSDictionary dictionaryWithObject:text forKey:@"comment"];
                NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
                NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [[OperationManager shareInstance] dispatchNormalThreadWithTarget:me selector:@selector(executeEditComment:threadObj:) argument:@[comment, body]];
            }
            else {
                [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_sorry", @"") message:NSLocalizedString(@"alert_please_enter_your_comment", @"")];
            }
        }
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)deleteComment:(CommentModel *)comment {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                                    message:NSLocalizedString(@"alert_delete_comment", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                          otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alert.context = comment;
    alert.tag = DELETECOMMENT_ALERT_TAG;
    [alert show];
}

#pragma mark - SupViewOfMoreInfoDelegate
- (void)openSellerProfilePage:(SellerModel *)seller {
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    vc.sellerModel = seller;
    vc.itemModel = self.itemModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)likeItem:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeLikeItem:threadObj:) argument:item];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_LIKE), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)wishlistItem:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeWishlistItem:threadObj:) argument:item];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_WISHLIST), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)flagItem:(ItemModel *)item {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeMarkFlagItem:threadObj:) argument:item];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_FLAG), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)shareItem:(ItemModel *)item {
    [[AppManager sharedInstance] shareItem:item viewController:self];
}

- (void)openFullDescription:(NSString *)title andDescription:(NSString *)desc {
    ReadMoreViewController *vc = [[ReadMoreViewController alloc] init];
    vc.pageTitle = title;
    vc.fullText = desc;
    vc.transitioningDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.view.frame = self.view.frame;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)openLikersPage:(ItemModel *)item {
    LikersViewController *vc = [[LikersViewController alloc] init];
    vc.itemModel = item;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)markInAppropriate:(ItemModel *)item {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"alert_mark_inappropriate", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"alert_button_yes", @""), nil];
    alertView.tag = INAPPROPRIATE_ALERT_TAG;
    [alertView show];
}

#pragma mark - Execute
- (void)executeGetCommenterInfo:(NSString *)userID threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getUserProfile:userID];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
        vc.sellerModel = [[SellerModel alloc] initWithDictionary:response.getJsonObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}
- (void)executeLikeItem:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager likeItem:[item getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [item updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.itemView setItemModel:item];
            [self.itemView updateContraintAndRenderScreenIfNeeded];
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIKED_ITEM_NOTIFICATION object:nil userInfo:userInfo];
        });
    }
    self.itemNeedUpdateAfterLogedIn = nil;
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
            [self.itemView setItemModel:item];
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict, };
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_WISHLISTED_ITEM_NOTIFICATION object:nil userInfo:userInfo];
        });
    }
    self.itemNeedUpdateAfterLogedIn = nil;
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeMarkFlagItem:(ItemModel *)item threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager markFlagOnItem:item];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        item.flagged = YES;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.itemView setItemModel:item];
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : [item getIdString]};
            [[NSNotificationCenter defaultCenter] postNotificationName:FLAG_ITEM_NOTIFICATION object:nil userInfo:userInfo];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadComments:(NSNumber *)shouldSrollToBottom threadObj:(id<OperationProtocol>)threadObj {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.commentsView startAnimating];
    });
    Response *response = [CloudManager getCommentsByItem:[self.itemModel getIdString] andFromPage:self.downloadedPage andPer:NUMBER_OF_COMMENT_PER_PAGE];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSArray *array = response.getJsonObject;
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            CommentModel *comment = [[CommentModel alloc] initWithDictionary:dict];
            if (comment) {
                [results addObject:comment];
            }
        }
        
        if (results.count > 0) {
            // increasing page for next request
            self.downloadedPage++;
            [self.comments addObjectsFromArray:results];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (self.comments.count > self.itemModel.total_comments) {
                    self.itemModel.total_comments = self.comments.count;
                    self.commentsView.lblNumberOfComment.text = [self.itemModel getNumberOfCommentsText];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_COMMENT_OF_ITEM_NOTIFICATION object:nil userInfo:nil];
                }
                self.commentsView.comments = self.comments;
                [self.commentsView updateHeightOfTableView];
                [self.commentsView reloadData];
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([shouldSrollToBottom boolValue]) {
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [self scrollToBottom];
            [self enableBackButton];
        }
        [self.commentsView stopAnimating:self.comments.count >= self.itemModel.total_comments];
    });
    [threadObj releaseOperation];
}

- (void)executeSendComment:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager addCommentForItem:[self.itemModel getIdString] andBody:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        CommentModel *comment = [[CommentModel alloc] initWithDictionary:dict];
        if (comment) {
            [self.comments insertObject:comment atIndex:0];
            self.commentsView.comments = self.comments;
            [self.itemModel updateLatestComment:dict];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.commentsView updateHeightOfTableView];
                [self.commentsView reloadData];
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
                
                [self scrollToBottom];
                
                [self.inputMessageView resetTextView];
                self.commentsView.lblNumberOfComment.text = [self.itemModel getNumberOfCommentsText];
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_COMMENT_OF_ITEM_NOTIFICATION object:nil userInfo:nil];
            });
        }
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeEditComment:(NSArray *)array threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    CommentModel *comment = [array objectAtIndex:0];
    NSString *body = [array objectAtIndex:1];
    Response *response = [CloudManager editCommentOfItem:[self.itemModel getIdString] withCommentId:[comment getIdString] andBody:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [comment updateWithDictionary:dict];
        for (CommentModel *cm in self.itemModel.latest_comments) {
            if ([[cm getIdString] isEqualToString:[comment getIdString]]) {
                [cm updateWithDictionary:dict];
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.commentsView updateHeightOfTableView];
            [self.commentsView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_COMMENT_OF_ITEM_NOTIFICATION object:nil userInfo:nil];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDeleteComment:(CommentModel *)comment threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager deleteCommentOfItem:[self.itemModel getIdString] withCommentId:[comment getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        [self.comments removeObject:comment];
        [self.itemModel.latest_comments removeAllObjects];
        for (int i = 0; i < 2 && i < self.comments.count; i++) {
            [self.itemModel.latest_comments addObject:[self.comments objectAtIndex:i]];
        }
        if (self.itemModel.total_comments > 0)
            self.itemModel.total_comments--;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.commentsView.lblNumberOfComment.text = [self.itemModel getNumberOfCommentsText];
            [self.commentsView updateHeightOfTableView];
            [self.commentsView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_COMMENT_OF_ITEM_NOTIFICATION object:nil userInfo:nil];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.sclview) {
        CGPoint offSet = self.sclview.contentOffset;
        if (self.comments == nil && (offSet.y + self.sclview.frame.size.height) >= CGRectGetMinY(self.commentsView.frame)) {
            self.comments = [[NSMutableArray alloc] init];
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadComments:threadObj:) argument:@(YES)];
        }
        if (!inputViewIsVisible && (offSet.y + self.sclview.frame.size.height) >= CGRectGetMinY(self.commentsView.frame)) {
            inputViewIsVisible = YES;

            CGRect rect = self.sclKeyboardAvoiding.frame;
            rect.origin.y = self.lcHeightInputView.constant;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [self.sclKeyboardAvoiding scrollRectToVisible:rect animated:NO];
                             }
                             completion:^(BOOL finished) {
                                 if (self.shouldAutoLoadComments) {
                                     self.shouldAutoLoadComments = NO;
                                     [self scrollToBottom];
                                 }
                             }];
        }
        if (inputViewIsVisible && (offSet.y + self.sclview.frame.size.height) <= CGRectGetMinY(self.commentsView.frame)) {
            inputViewIsVisible = NO;
            CGRect rect = self.sclKeyboardAvoiding.frame;
            rect.origin.y = 0;
            [self.sclKeyboardAvoiding scrollRectToVisible:rect animated:YES];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == DELETECOMMENT_ALERT_TAG) {
        if (buttonIndex == 1) {
            if ([alertView.context isKindOfClass:[CommentModel class]]) {
                CommentModel *comment = alertView.context;
                [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDeleteComment:threadObj:) argument:comment];
            }
        }
    }
    else if (alertView.tag == INAPPROPRIATE_ALERT_TAG) {
        if (buttonIndex == 1) {
            [self flagItem:self.itemModel];
        }
    }
}

#pragma mark - ImagesScrollViewDelegate
- (void)popupZoomingImages:(NSArray *)images currentIndex:(NSInteger)index {
    ImagePopupViewController *vc = [[ImagePopupViewController alloc] init];
    vc.images = images;
    vc.currentIndex = index;
    [self presentViewController:vc animated:NO completion:nil];
}
@end
