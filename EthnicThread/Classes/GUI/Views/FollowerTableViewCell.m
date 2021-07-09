//
//  FollowerTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "FollowerTableViewCell.h"
#import "AvatarButton.h"
#import "Constants.h"
#import "UIButton+Custom.h"

@interface FollowerTableViewCell()
@property (nonatomic, assign) IBOutlet AvatarButton         *btnAvatar;
@property (nonatomic, assign) IBOutlet UIButton             *btnUnfollow;
@property (nonatomic, assign) IBOutlet UILabel              *lblFullName;
@property (nonatomic, assign) IBOutlet UIButton             *btnLocation;
@property (nonatomic, assign) IBOutlet UIButton             *btnItemCount;

@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidthUnfollowButton;
@end

@implementation FollowerTableViewCell

- (void)awakeFromNib {
    self.btnUnfollow.layer.borderColor = ORANGE_COLOR.CGColor;
    self.btnUnfollow.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setSellerModel:(SellerModel *)sellerModel {
    _sellerModel = sellerModel;
    self.lblFullName.text = [self.sellerModel getDisplayName];
    [self.btnLocation setTitle:[self.sellerModel getLocation] forState:UIControlStateNormal];
    [self.btnItemCount setTitle:[self.sellerModel getItemsCountText] forState:UIControlStateNormal];
    [self.btnAvatar loadImageForUrl:self.sellerModel.avatar];
}

- (IBAction)handleUnfollowButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(unfollow:andSeller:)]) {
        [self.delegate unfollow:self andSeller:self.sellerModel];
    }
}

- (void)allowUnfollow:(BOOL)allow {
    [self.btnUnfollow setHidden:!allow];
    if (allow) {
        self.lcWidthUnfollowButton.constant = 87;
    }
    else {
        self.lcWidthUnfollowButton.constant = 0;
    }
}
@end
