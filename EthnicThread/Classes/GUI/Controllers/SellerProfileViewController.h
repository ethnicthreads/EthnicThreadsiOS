//
//  ProfileViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/22/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "SellerModel.h"

@interface SellerProfileViewController : BaseViewController
@property (nonatomic, strong) SellerModel        *sellerModel;
@property (nonatomic, strong) ItemModel          *itemModel;
@property (nonatomic, assign) BOOL               shouldAutoLoadReviews;

- (void)sendActionToServerIfNeed:(NSDictionary *)notifUserInfo;
@end
