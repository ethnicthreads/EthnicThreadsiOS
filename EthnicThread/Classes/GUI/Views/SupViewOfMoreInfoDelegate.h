//
//  SupViewOfMoreInfoDelegate.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/3/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemModel.h"
#import "SellerModel.h"

@protocol SupViewOfMoreInfoDelegate <NSObject>
@optional
- (void)openSellerProfilePage:(SellerModel *)seller;
- (void)likeItem:(ItemModel *)item;
- (void)wishlistItem:(ItemModel *)item;
- (void)shareItem:(ItemModel *)item;
- (void)openFullDescription:(NSString *)title andDescription:(NSString *)desc;
- (void)openAllReviewsPage;
- (void)openNewReviewPage;
- (void)contactSeller:(SellerModel *)seller;
- (void)openLikersPage:(ItemModel *)item;
- (void)markInAppropriate:(ItemModel *)item;
@end
