//
//  CommentReviewTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/21/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "AvatarButton.h"
#import "MessageLabel.h"
#import "Constants.h"
#import "UIButton+Custom.h"

@interface CommentTableViewCell()
@property (nonatomic, assign) IBOutlet UIButton             *btnName;
@property (nonatomic, assign) IBOutlet UIView               *vSlot;
@property (nonatomic, assign) IBOutlet AvatarButton         *btnAvatar;
@property (nonatomic, assign) IBOutlet UIView               *vTop;
@property (nonatomic, assign) IBOutlet MessageLabel         *lblMessage;
@property (nonatomic, assign) IBOutlet UILabel              *lblCreatedDate;
@property (nonatomic, assign) IBOutlet UIView               *vBottom;
@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.vTop setBackgroundColor:LIGHT_GRAY_COLOR];
    [self.lblMessage setBackgroundColor:LIGHT_GRAY_COLOR];
    [self.vSlot setBackgroundColor:LIGHT_GRAY_COLOR];
    [self.vBottom setBackgroundColor:LIGHT_GRAY_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lblMessage.preferredMaxLayoutWidth = CGRectGetWidth(self.lblMessage.frame);
}

- (void)setComment:(CommentModel *)comment {
    _comment = comment;
    [self.btnName setTitle:[comment.owner getDisplayName] forState:UIControlStateNormal];
    self.lblCreatedDate.text = [comment getCreatedDateString];
    self.lblMessage.text = comment.comment;
    [self.btnAvatar loadImageForUrl:comment.owner.avatar];
}

- (void)setCommentToCalculateHeightOfCell:(CommentModel *)comment {
    _comment = comment;
    self.lblMessage.text = comment.comment;
}

- (IBAction)handlerUserProfileButton:(id)sender {
    if ([self.ownerDelegate respondsToSelector:@selector(openUserProfilePage:)]) {
        [self.ownerDelegate openUserProfilePage:self.comment.owner];
    }
}
@end
