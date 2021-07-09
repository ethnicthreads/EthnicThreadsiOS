//
//  ItemTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/28/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemModel.h"
#import "AvatarButton.h"
#import "UIImageView+Custom.h"
#import "SellerModel.h"
#import "ImagesScrollView.h"

@protocol ItemTableViewCellDelegate <NSObject>
- (void)openMoreInfoPage:(ItemModel *)item sender:(id)sender;
- (void)openCommentPage:(ItemModel *)item sender:(id)sender;
- (void)buyNow:(ItemModel *)item sender:(id)sender;
- (void)openSellerProfilePage:(ItemModel *)item sender:(id)sender;
- (void)likeItem:(ItemModel *)item;
- (void)wishlistItem:(ItemModel *)item;
- (void)shareItem:(ItemModel *)item;
- (void)openLikersPage:(ItemModel *)item;
- (void)openCommentsPage:(ItemModel *)item sender:(id)sender;
- (void)openLikerProfilePage:(SellerModel *)seller;
- (void)openFollowersPage:(SellerModel *)seller;
- (void)markInAppropriate:(ItemModel *)item;
- (void)updateSellerFollowStatus:(ItemModel *)item;
- (void)seeMorePost:(SellerModel *)seller;
@optional
- (void)editItem:(ItemModel *)item;
- (void)updateItemStatus:(ItemModel *)item withStatus:(NSString *)status;
- (void)removeItem:(ItemModel *)item;
- (void)removeItemFromWishlist:(ItemModel *)item;
@end

@interface ItemTableViewCell : UITableViewCell
@property (nonatomic, assign) IBOutlet ImagesScrollView     *scvGallery;
@property (nonatomic, weak) id <ItemTableViewCellDelegate>  delegate;
@property (nonatomic, strong) ItemModel                     *itemModel;
@property (nonatomic, assign) BOOL                          hasRightMenu;
@property (nonatomic, assign) BOOL                          inWishlistPage;

- (void)closeRightMenu:(BOOL)animate;
- (void)setItemModelToCalcHeightOfCell:(ItemModel *)itemModel;
- (UIImage *)getAvatar;
- (void)setAvatar:(UIImage *)avatarImage;
- (UIImage *)getFirstImage;
- (void)setFirstImage:(UIImage *)firstImage;
- (CGFloat)cellHeight;
@end
