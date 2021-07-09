//
//  ProfileViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/22/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SellerProfileViewController.h"
#import "UserProfileView.h"
#import "MenuViewController.h"
#import "AnimatedTransitioning.h"
#import "ContactSellerViewController.h"
#import "StarRatingView.h"
#import "UIAlertView+Custom.h"
#import "Constants.h"
#import "CommentsView.h"
#import "InputMessageView.h"
#import "FollowersViewController.h"
#import "ListedItemsViewController.h"
#import "CustomIOS7AlertView.h"

#define USERINFO_ACTION_KEY      @"userinfo_action_key"
#define NUMBER_OF_REVIEWS_PER_PAGE     5

@interface SellerProfileViewController() <UserProfileViewDelegate, UIViewControllerTransitioningDelegate, UIAlertViewDelegate, UIScrollViewDelegate, CommentsViewDelegate> {
    BOOL    inputViewIsVisible;
}
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcEqualWidthFollowContactButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHorizontalFollowContactButton;
@property (nonatomic, strong) NSLayoutConstraint            *lcTrailingFollowButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHeightContentView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcWidthContentView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHeightFloatingView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *lcHeightInputView;

@property (nonatomic, assign) IBOutlet UIView               *floatingButtonView;
@property (nonatomic, assign) IBOutlet InputMessageView     *inputMessageView;
@property (nonatomic, strong) IBOutlet UIScrollView         *sclKeyboardAvoiding;
@property (nonatomic, strong) IBOutlet UIScrollView         *sclview;
@property (nonatomic, strong) UIView                        *vContent;
@property (nonatomic, strong) UserProfileView               *userProfileView;
@property (nonatomic, strong) CommentsView                  *reviewsView;
@property (nonatomic, assign) id<OperationProtocol>         runningThread;
@property (nonatomic, assign) id<OperationProtocol>         reviewingThread;
@property (nonatomic, strong) IBOutlet UIButton             *btnFollow;
@property (nonatomic, strong) IBOutlet UIButton             *btnContact;
@property (nonatomic, assign) NSInteger                     downloadedPage;
@property (nonatomic, strong) NSMutableArray                *reviews;
@end

@implementation SellerProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initVariables {
    [super initVariables];
    self.downloadedPage = 1;
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:@"Profile" andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    if (self.shouldAutoLoadReviews) {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        [self performSelector:@selector(enableBackButton) withObject:nil afterDelay:2.0];
    }
    
    [self.sclview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)]];
    self.sclview.delegate = self;
    
    self.inputMessageView.lcHeight = self.lcHeightInputView;
    [self.inputMessageView.btnSend addTarget:self action:@selector(handleSendReviewButton:) forControlEvents:UIControlEventTouchUpInside];
    self.inputMessageView.textView.placeholder = NSLocalizedString(@"type_a_review", @"");
    inputViewIsVisible = NO;
    
    NSLayoutConstraint *lc;
    self.vContent = [[UIView alloc] initWithFrame:CGRectZero];
    
    //user profile
    self.userProfileView = [[[UINib nibWithNibName:NSStringFromClass([UserProfileView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.userProfileView.delegate = self;
    [self.userProfileView displayUserProfile:self.sellerModel];
    [self.userProfileView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vContent addSubview:self.userProfileView];
    lc = [NSLayoutConstraint constraintWithItem:self.userProfileView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.userProfileView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.userProfileView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    [self.userProfileView displayUserProfile:self.sellerModel];
    
    //user reviews
    self.reviewsView = [[[UINib nibWithNibName:NSStringFromClass([CommentsView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.reviewsView.delegate = self;
    self.reviewsView.allowDeleteAnyComment = [self.sellerModel isMe];
    self.reviewsView.lblNumberOfComment.text = [self.sellerModel getNumberOfReviewsText];
    [self.reviewsView stopAnimating:self.reviews.count >= self.sellerModel.total_reviews];
    [self.reviewsView.btnLoadMore setTitle:NSLocalizedString(@"view_previous_reviews", @"") forState:UIControlStateNormal];
    [self.reviewsView.btnLoadMore addTarget:self action:@selector(handleLoadOldReviewsButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.reviewsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vContent addSubview:self.reviewsView];
    lc = [NSLayoutConstraint constraintWithItem:self.reviewsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.reviewsView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.reviewsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userProfileView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.vContent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.reviewsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
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
    
    [self.btnFollow setTitle:[self.sellerModel getFollowStatusString] forState:UIControlStateNormal];
    
    if (!self.sellerModel.hasFullData) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetUserProfile:threadObj:) argument:@""];
    }
    
    [self.floatingButtonView setHidden:([self.sellerModel isMe])];
}

- (void)updateViewConstraints {
    self.lcHeightFloatingView.constant = ([self.sellerModel isMe]) ? 0 : 40;
    self.lcWidthContentView.constant = [UIScreen mainScreen].bounds.size.width;
    self.lcHeightContentView.constant = [UIScreen mainScreen].bounds.size.height - (self.lcTop.constant + self.lcHeightFloatingView.constant) + self.lcHeightInputView.constant;
    [super updateViewConstraints];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.shouldAutoLoadReviews) {
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
            case ACTION_UPDATE_FOLLOWED_SELLER: {
                if (!self.sellerModel.followed) {
                    [self handleFollowSellerButton:self.btnFollow];
                }
            }
                break;
            case ACTION_RATE_SELLER: {
                if (!self.sellerModel.rated) {
                    [self rateSeller:self.sellerModel];
                }
            }
                break;
            case ACTION_REVIEW_SELLER: {
                [self handleSendReviewButton:self.inputMessageView.btnSend];
            }
                break;
            case ACTION_CONTACT_SELLER: {
                [self handleContactSellerButton:self.btnContact];
            }
                break;
            default:
                break;
        }
    }
}

- (void)handlerLeftNavigationItem:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleLoadOldReviewsButton:(id)sender {
    self.shouldAutoLoadReviews = NO;
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadReviews:threadObj:) argument:@(NO)];
}

- (void)didTapOnTableView:(UIGestureRecognizer *)recognizer {
    [self.inputMessageView.textView resignFirstResponder];
}

- (void)handleSendReviewButton:(id)sender {
    if ([self.reviewingThread isReady])
        return;
    NSString *review = [self.inputMessageView.textView.text trimText];
    review = [Utils convertEmojiToUnicode:review];
    if (review.length > 0) {
        if ([[UserManager sharedInstance] isLogin]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:review forKey:@"review"];
            self.reviewingThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeSendReview:threadObj:) argument:dict];
        }
        else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_REVIEW_SELLER), USERINFO_ACTION_KEY, nil];
            [self showAlertToRequireLogin:userInfo];
        }
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_sorry", @"") message:NSLocalizedString(@"alert_please_enter_your_review", @"")];
    }
}

- (void)executeGetUserProfile:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getUserProfile:[self.sellerModel getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response.getJsonObject];
        [self.sellerModel updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.userProfileView displayUserProfile:self.sellerModel];
            [self.btnFollow setTitle:[self.sellerModel getFollowStatusString] forState:UIControlStateNormal];
            
            [self.btnFollow setTitle:[self.sellerModel getFollowStatusString] forState:UIControlStateNormal];
            self.reviewsView.lblNumberOfComment.text = [self.sellerModel getNumberOfReviewsText];
            [self.reviewsView stopAnimating:self.reviews.count >= self.sellerModel.total_reviews];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeUpdateFollowThisSeller:(SellerModel *)seller threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager updateFollowASeller:[seller getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [self.sellerModel updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FOLLOWED_USER_NOTIFICATION object:nil userInfo:userInfo];
            
            [self.userProfileView displayUserProfile:self.sellerModel];
            [self.btnFollow setTitle:[self.sellerModel getFollowStatusString] forState:UIControlStateNormal];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeRateSeller:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager rateSeller:[self.sellerModel getIdString] andBody:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [self.sellerModel updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *userInfo = @{NOTIFICATION_USERINFO_KEY : dict};
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RATE_USER_NOTIFICATION object:nil userInfo:userInfo];
            
            [self.userProfileView displayUserProfile:self.sellerModel];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadReviews:(NSNumber *)shouldSrollToBottom threadObj:(id<OperationProtocol>)threadObj {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.reviewsView startAnimating];
    });
    Response *response = [CloudManager getReviewsBySeller:[self.sellerModel getIdString] andFromPage:self.downloadedPage andPer:NUMBER_OF_REVIEWS_PER_PAGE];
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
            //            [self.reviews addObjectsFromArray:results];
            self.reviews = [NSMutableArray arrayWithArray:results];
            
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (self.reviews.count > self.sellerModel.total_reviews) {
                    self.sellerModel.total_reviews = self.reviews.count;
                    self.reviewsView.lblNumberOfComment.text = [self.sellerModel getNumberOfReviewsText];
                }
                self.reviewsView.comments = self.reviews;
                [self.reviewsView updateHeightOfTableView];
                [self.reviewsView reloadData];
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
        [self.reviewsView stopAnimating:self.reviews.count >= self.sellerModel.total_reviews];
    });
    [threadObj releaseOperation];
}

- (void)executeSendReview:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager addReviewForSeller:[self.sellerModel getIdString] andBody:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        CommentModel *review = [[CommentModel alloc] initWithDictionary:dict];
        if (review) {
            [self.reviews insertObject:review atIndex:0];
            self.reviewsView.comments = self.reviews;
            [self.sellerModel updateLatestReview:dict];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.reviewsView updateHeightOfTableView];
                [self.reviewsView reloadData];
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
                
                CGRect rect = self.sclview.frame;
                rect.origin.y = self.sclview.contentSize.height - self.sclview.frame.size.height;
                [self.sclview scrollRectToVisible:rect animated:YES];
                
                [self.inputMessageView resetTextView];
                self.reviewsView.lblNumberOfComment.text = [self.sellerModel getNumberOfReviewsText];
            });
        }
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeEditReview:(NSArray *)array threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    CommentModel *review = [array objectAtIndex:0];
    NSString *body = [array objectAtIndex:1];
    Response *response = [CloudManager editReviewOfSeller:[self.sellerModel getIdString] withReviewId:[review getIdString] andBody:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        [review updateWithDictionary:dict];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.reviewsView updateHeightOfTableView];
            [self.reviewsView reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDeleteReview:(CommentModel *)review threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager deleteReviewOfSeller:[self.sellerModel getIdString] withReviewId:[review getIdString]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        [self.reviews removeObject:review];
        if (self.sellerModel.total_reviews > 0)
            self.sellerModel.total_reviews--;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.reviewsView.lblNumberOfComment.text = [self.sellerModel getNumberOfReviewsText];
            [self.reviewsView updateHeightOfTableView];
            [self.reviewsView reloadData];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (IBAction)handleContactSellerButton:(id)sender {
    if ([[UserManager sharedInstance] isLogin]) {
        ContactSellerViewController *vc = [[ContactSellerViewController alloc] init];
        vc.userId = [self.sellerModel getIdString];
        vc.fullName = [self.sellerModel getDisplayName];
        vc.itemModel = self.itemModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_CONTACT_SELLER), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (IBAction)handleFollowSellerButton:(id)sender {
    if ([[UserManager sharedInstance] isLogin]) {
        if (![self.runningThread isReady])
            self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateFollowThisSeller:threadObj:) argument:self.sellerModel];
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_UPDATE_FOLLOWED_SELLER), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

#pragma mark - CommentsViewDelegate
- (void)openCommenter:(SellerModel *)commenter {
    [self.inputMessageView.textView resignFirstResponder];
    // Open reviewer
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    vc.sellerModel = commenter;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectRowOfComment:(CommentModel *)comment {
    [self.inputMessageView.textView resignFirstResponder];
}

- (void)editComment:(CommentModel *)comment {
    // edit review
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 150)];
    ETPlaceHolderTextView *textView = [[ETPlaceHolderTextView alloc] initWithFrame:CGRectMake(10, 10, 250, 130)];
    textView.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
    textView.layer.borderWidth = 1;
    [textView setFont:[UIFont systemFontOfSize:MEDIUM_FONT_SIZE]];
    [textView setTextColor:BLACK_COLOR_TEXT];
    textView.placeholder = NSLocalizedString(@"type_a_review", @"");
    textView.text = comment.comment;
    [demoView addSubview:textView];
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    [alertView setContainerView:demoView];
    [alertView setButtonTitles:@[NSLocalizedString(@"alert_button_cancel", @""), NSLocalizedString(@"alert_button_save", @"")]];
    __block SellerProfileViewController *me = self;
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1) {
            NSString *text = [textView.text trimText];
            if (text.length > 0) {
                NSDictionary *param = [NSDictionary dictionaryWithObject:text forKey:@"review"];
                NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
                NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [[OperationManager shareInstance] dispatchNormalThreadWithTarget:me selector:@selector(executeEditReview:threadObj:) argument:@[comment, body]];
            }
            else {
                [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_sorry", @"") message:NSLocalizedString(@"alert_please_enter_your_review", @"")];
            }
        }
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)deleteComment:(CommentModel *)comment {
    // delete review
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                                    message:NSLocalizedString(@"alert_delete_review", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                          otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alert.context = comment;
    [alert show];
}

#pragma mark - UserProfileViewDelegate
- (void)rateSeller:(SellerModel *)seller {
    if ([[UserManager sharedInstance] isLogin]) {
        if (!(self.sellerModel.rated || [self.sellerModel isMe])) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"please_rate", @"")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                                      otherButtonTitles:NSLocalizedString(@"alert_button_send", @""), nil];
            
            StarRatingView *starView = [[StarRatingView alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
            starView.allowRating = YES;
            [alertView setValue:starView forKey:@"accessoryView"];
            alertView.context = starView;
            [alertView show];
        }
    }
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(ACTION_RATE_SELLER), USERINFO_ACTION_KEY, nil];
        [self showAlertToRequireLogin:userInfo];
    }
}

- (void)openFollowerPage:(SellerModel *)seller {
    FollowersViewController *vc = [[FollowersViewController alloc] init];
    vc.userModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openListedItemsPage:(SellerModel *)seller {
    ListedItemsViewController *vc = [[ListedItemsViewController alloc] init];
    vc.userModel = seller;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView.context isKindOfClass:[StarRatingView class]]) {
            StarRatingView *view = alertView.context;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSString stringWithFormat:@"%ld", (long)view.rating] forKey:@"rating"];
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeRateSeller:threadObj:) argument:dict];
        }
        else if ([alertView.context isKindOfClass:[CommentModel class]]) {
            CommentModel *review = alertView.context;
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDeleteReview:threadObj:) argument:review];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.sclview) {
        CGPoint offSet = self.sclview.contentOffset;
        if (self.reviews == nil && (offSet.y + self.sclview.frame.size.height) >= CGRectGetMinY(self.reviewsView.frame)) {
            self.reviews = [[NSMutableArray alloc] init];
            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadReviews:threadObj:) argument:@(YES)];
        }
        if (!inputViewIsVisible && (offSet.y + self.sclview.frame.size.height) >= CGRectGetMinY(self.reviewsView.frame)) {
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
                                 if (self.shouldAutoLoadReviews) {
                                     self.shouldAutoLoadReviews = NO;
                                     [self scrollToBottom];
                                 }
                             }];
        }
        if (inputViewIsVisible && (offSet.y + self.sclview.frame.size.height) <= CGRectGetMinY(self.reviewsView.frame)) {
            inputViewIsVisible = NO;
            CGRect rect = self.sclKeyboardAvoiding.frame;
            rect.origin.y = 0;
            [self.sclKeyboardAvoiding scrollRectToVisible:rect animated:YES];
        }
    }
}
@end
