//
//  UserProfileView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/2/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "SellerModel.h"
#import "CustomImageView.h"

@protocol UserProfileViewDelegate <NSObject>
- (void)rateSeller:(SellerModel *)seller;
- (void)openFollowerPage:(SellerModel *)seller;
- (void)openListedItemsPage:(SellerModel *)seller;
@end

@interface UserProfileView : BaseView
@property (nonatomic, assign) id <UserProfileViewDelegate> delegate;

- (void)displayUserProfile:(SellerModel *)aUser;
@end
