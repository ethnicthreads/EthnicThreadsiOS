//
//  MessageTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageLabel.h"

@interface MessageTableViewCell()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightMessage;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightItem;

@property (nonatomic, assign) IBOutlet UIView               *vSlot;
@property (nonatomic, assign) IBOutlet UIView               *vItem;
@property (nonatomic, assign) IBOutlet UILabel              *lblItemTitle;
@property (nonatomic, assign) IBOutlet UILabel              *lblItemtId;
@property (nonatomic, assign) IBOutlet CustomImageView      *imvItemImage;

@property (nonatomic, assign) IBOutlet AvatarButton         *btnAvatar;
@property (nonatomic, assign) IBOutlet UIView               *vMessage;
@property (nonatomic, assign) IBOutlet MessageLabel         *lblMessage;
@property (strong, nonatomic) IBOutlet UIImageView *imvImage;
@property (nonatomic, assign) IBOutlet UIButton             *btnName;
@property (nonatomic, assign) IBOutlet UILabel              *lblCreatedDate;
@property (nonatomic, assign) IBOutlet UIView               *vBottom;
@end

@implementation MessageTableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.imvImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    [self.imvImage addGestureRecognizer:tapGesture];
}

- (void)didTapImage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openFullImage:)]) {
        [self.delegate openFullImage:self.imvImage.image];
    }
}

- (void)setMessage:(MessageModel *)message {
    _message = message;
    [self caculateHeightByMessage:message];
    
    [self.btnName setTitle:[message.sender getDisplayName] forState:UIControlStateNormal];
    self.lblCreatedDate.text = [message getCreatedDateString];
    if (self.message.itemModel) {
        self.lblItemTitle.text = self.message.itemModel.name;
        self.lblItemtId.text = [NSString stringWithFormat:@"#%@", [self.message.itemModel getIdString]];
        [self.imvItemImage setImage:[UIImage imageNamed:ITEM_THUMB]];
        [self.imvItemImage loadImageForUrl:[self.message.itemModel getFirstImageUrl]];
    }
    
    if ([message isImageType]) {
        [self.imvImage loadImageForUrl:message.imageUrl type:IMAGE_SCALE defaultImage:[UIImage imageNamed:@"message_placeholder.gif"]];
    } else {
        [self.imvImage setImage:nil];
    }
    
    UIColor *color = LIGHT_GRAY_COLOR;
    if ([message isMine]) {
        color = LIGHT_PURPLE_COLOR;
    }
    [self.vMessage setBackgroundColor:color];
    [self.lblMessage setBackgroundColor:color];
    [self.vSlot setBackgroundColor:color];
    [self.vItem setBackgroundColor:color];
    [self.vBottom setBackgroundColor:color];
    
    [self.vItem setHidden:self.message.itemModel == nil];
    
    [self.btnAvatar loadImageForUrl:self.message.sender.avatar];
}

- (void)caculateHeightByMessage:(MessageModel *)message {
    _message = message;
    if ([message isImageType]) {
        self.lcHeightMessage.constant = 0;
        self.lblMessage.text = nil;
    } else {
        self.lcHeightMessage.constant = 21;
        self.lblMessage.text = message.message;
    }
    self.lcHeightItem.constant = self.message.itemModel ? 58 : 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lblMessage.preferredMaxLayoutWidth = CGRectGetWidth(self.lblMessage.frame);
}

- (IBAction)handleItemButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openMoreInfoPage:)]) {
        [self.delegate openMoreInfoPage:self.message.itemModel];
    }
}

- (IBAction)handleUserButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]) {
        [self.delegate openUserProfilePage:self.message.sender];
    }
}
@end
