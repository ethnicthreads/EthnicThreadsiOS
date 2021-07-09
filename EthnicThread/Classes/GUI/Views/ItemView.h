//
//  ItemView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/28/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "SupViewOfMoreInfoDelegate.h"
#import "ItemModel.h"
#import "EditItemDelegate.h"
#import "ImagesScrollView.h"

@interface ItemView : BaseView
@property (nonatomic, assign) IBOutlet ImagesScrollView      *scvGallery;
@property (nonatomic, assign) IBOutlet UIView                *vContent;
@property (nonatomic, assign) id <SupViewOfMoreInfoDelegate> delegate;
@property (nonatomic, assign) id <EditItemDelegate>          editDelegate;
@property (nonatomic, strong) ItemModel                      *itemModel;
@property (nonatomic, assign) BOOL                           allowEdit;

- (void)updateLikeUI:(BOOL)liked;
- (void)updateWishlistUI:(BOOL)wishlisted;
- (void)updateImages:(NSMutableArray *)images;
- (void)setAvatar:(UIImage *)avatarImage;
- (void)setFirstImage:(UIImage *)firstImage;
@end
