//
//  GalleryCollectionViewCell.h
//  EthnicThread
//
//  Created by DuyLoc on 4/7/17.
//  Copyright © 2017 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemModel.h"

@protocol GalleryCollectionViewCellDelegate <NSObject>

- (void)didOpenItem:(ItemModel *)item sender:(id)sender;
- (void)didOpenSellerInfo:(ItemModel *)item;
- (void)removeItem:(ItemModel *)item;
- (void)editItem:(ItemModel *)item;
- (void)likeItem:(ItemModel *)item;
- (void)updateItemStatus:(ItemModel *)item withStatus:(NSString *)status;
- (void)updateSellerFollowStatus:(ItemModel *)item;
@end

@interface GalleryCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lcHeightImItem;
@property (nonatomic, strong) ItemModel *item;
@property (strong, nonatomic) IBOutlet UIImageView *imItem;
@property (nonatomic, assign) id<GalleryCollectionViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL isMyPosting;
- (CGFloat)cellHeight;
- (void)configureCellForItem:(ItemModel *)item;
- (UIImage *)getAvatarImage;
- (UIImage *)getFirstImage;
- (void)allowEdit;
@end
