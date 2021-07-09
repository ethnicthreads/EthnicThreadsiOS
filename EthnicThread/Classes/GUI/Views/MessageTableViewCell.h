//
//  MessageTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvatarButton.h"
#import "Constants.h"
#import "MessageModel.h"
#import "CustomImageView.h"
#import "UIButton+Custom.h"
#import "UIImageView+Custom.h"

@protocol MessageTableViewCellDelegate <NSObject>
- (void)openMoreInfoPage:(ItemModel *)itemModel;
- (void)openUserProfilePage:(SellerModel *)sellerModel;
- (void)openFullImage:(UIImage *)image;
@end

@interface MessageTableViewCell : UITableViewCell
@property (nonatomic, strong) MessageModel                  *message;
@property (nonatomic, assign) id <MessageTableViewCellDelegate> delegate;

- (void)caculateHeightByMessage:(MessageModel *)message;
@end
