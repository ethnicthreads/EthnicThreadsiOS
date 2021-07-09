//
//  Item.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/11/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseItemModel.h"
#import "SellerModel.h"
#import "CommentModel.h"
#import "ItemSellerProtocol.h"

#define STATUS_UNAVAILABLE      @"unavailable"

@protocol ItemModelDelegate <NSObject>
@optional
- (void)didFinishLoadingAvatar:(UIImage *)image sender:(id)sender;
- (void)didFinishLoadingFirstImage:(UIImage *)image sender:(id)sender;
- (void)didHaveErrorWhileLoadingImaeUrl:(NSString *)url sender:(id)sender;
@end

@interface ItemModel : BaseItemModel <ItemSellerProtocol>
@property (strong, nonatomic) NSString      *status;//"sold,unavallable"
@property (strong, nonatomic) NSString      *sizes;
@property (strong, nonatomic) NSString      *tags;
@property (strong, nonatomic) NSString      *purchases;
@property (nonatomic) BOOL                  liked;
@property (nonatomic) BOOL                  commented;
@property (nonatomic) NSInteger             total_likes;
@property (nonatomic) NSInteger             total_comments;
@property (nonatomic) NSInteger             total_followers;
@property (nonatomic) BOOL                  in_wish_list;
@property (nonatomic, assign) double        created_at;
@property (nonatomic) BOOL                  flagged;
@property (strong, nonatomic) SellerModel   *sellerModel;
@property (strong, nonatomic) NSMutableArray *latest_likers;
@property (strong, nonatomic) NSMutableArray *latest_comments;
@property (nonatomic, assign) id <ItemModelDelegate>           aDelegate;
@property (strong, nonatomic) NSMutableArray    *imageItems;
@property (nonatomic, assign) CGFloat           cellHeight;
@property (nonatomic, assign) BOOL           imageLoaded;
@property (nonatomic, strong) UIImage *cachedFirstImage;

- (NSString *)getPriceWithCurencyText;
- (NSString *)getNumberOfLikesText;
- (NSString *)getNumberOfCommentsText;
- (NSString *)getCommentTextAndNumber;
- (NSString *)getGenderString;
- (UIImage *)getGenderImage;
- (NSString *)getSizeString;
- (NSString *)getStatusString;
- (NSString *)getFirstImageUrl;
- (NSMutableArray *)getAllImageUrls;
- (NSString *)getDisplayedTags;
- (NSString *)getPurchasesText;
- (NSString *)createAtString;
- (NSString *)getSellerFollowStatus;
- (BOOL)isUnavallable;
- (BOOL)isEqualToDictionaryOfItem:(NSDictionary *)dict;
- (void)resetStatus;
- (BOOL)isMine;
- (NSString *)getItemShareLink;
- (void)loadAvatar;
- (void)loadFirstImage;
- (void)downloadReparatoryImages;
- (void)cancel;
@end
