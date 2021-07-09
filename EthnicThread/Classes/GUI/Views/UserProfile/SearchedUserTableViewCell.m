//
//  SearchedUserTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/27/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "SearchedUserTableViewCell.h"
#import "Constants.h"
#import "AvatarButton.h"
#import "UIButton+Custom.h"

@interface SearchedUserTableViewCell()
@property (nonatomic, strong) IBOutlet UILabel      *lblDisplayName;
@property (nonatomic, strong) IBOutlet UILabel      *lblAddress;
@property (nonatomic, strong) IBOutlet AvatarButton *btnAvatar;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcLeadingDisplayNameLabel;
@end

@implementation SearchedUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lblAddress.preferredMaxLayoutWidth = CGRectGetWidth(self.lblAddress.frame);
}

- (void)setSearchUser:(BasicInfoUserModel *)searchUser {
    if (searchUser.isAnySeller) {
        [self.btnAvatar setHidden:YES];
        [self.lblAddress setHidden:YES];
        self.lcLeadingDisplayNameLabel.constant = 10;
        self.lblDisplayName.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
    }
    else {
        [self.btnAvatar setHidden:NO];
        [self.lblAddress setHidden:NO];
        self.lcLeadingDisplayNameLabel.constant = 53;
        self.lblDisplayName.font = [UIFont boldSystemFontOfSize:MEDIUM_FONT_SIZE];
    }
    
    self.lblDisplayName.text = [searchUser getDisplayName];
    self.lblAddress.text = [searchUser getLocation];
    [self.btnAvatar loadImageForUrl:searchUser.avatar];
}
@end
