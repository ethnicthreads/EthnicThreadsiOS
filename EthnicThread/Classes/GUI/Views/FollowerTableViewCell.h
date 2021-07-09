//
//  FollowerTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SellerModel.h"

@protocol FollowerTableViewCellDelegate <NSObject>
- (void)unfollow:(id)sender andSeller:(SellerModel *)sellerModel;
@end

@interface FollowerTableViewCell : UITableViewCell
@property (nonatomic, strong) SellerModel                   *sellerModel;
@property (nonatomic, assign) id <FollowerTableViewCellDelegate>    delegate;

- (void)allowUnfollow:(BOOL)allow;
@end
