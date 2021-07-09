//
//  SellerModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/15/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UserModel.h"
#import "ItemSellerProtocol.h"

@interface SellerModel : UserModel <ItemSellerProtocol>
@property (nonatomic) NSInteger              total_items;
@property (nonatomic) NSInteger              total_reviews;
@property (nonatomic) BOOL                   followed;
@property (nonatomic) BOOL                   hasFullData;

- (NSString *)getNumberOfReviewsText;
- (NSString *)getItemsCountText;
- (NSString *)getFollowStatusString;
@end
