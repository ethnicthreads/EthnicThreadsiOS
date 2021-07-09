//
//  ThreadTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ThreadTableViewCell.h"
#import "AvatarButton.h"
#import "Constants.h"
#import "UIButton+Custom.h"

@interface ThreadTableViewCell()
@property (nonatomic, assign) IBOutlet AvatarButton         *btnAvatar;
@property (nonatomic, assign) IBOutlet UILabel              *lblItemTitle;
@property (nonatomic, assign) IBOutlet UIImageView          *imvLetter;
@property (nonatomic, assign) IBOutlet UILabel              *lblMessage;
@property (nonatomic, assign) IBOutlet UILabel              *lblName;
@property (nonatomic, assign) IBOutlet UILabel              *lblCreatedDate;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTrailingLetterImageView;
@end

@implementation ThreadTableViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setThread:(ThreadModel *)thread {
    _thread = thread;
//    self.lblMessage.text = [Utils convertUnicodeToEmoji:self.thread.message];
    self.lblMessage.text = self.thread.message;
    self.lblCreatedDate.text = [self.thread getCreatedDateString];
    self.lblItemTitle.text = self.thread.itemModel.name;
    if ([self.thread isMine]) {
        self.lblName.text = [self.thread.receiver getDisplayName];
        [self.btnAvatar loadImageForUrl:self.thread.receiver.avatar];
        [self.imvLetter setImage:[UIImage imageNamed:@"sent_message_icon"]];
        self.lcTrailingLetterImageView.constant = 3;
    }
    else {
        self.lblName.text = [thread.sender getDisplayName];
        [self.btnAvatar loadImageForUrl:self.thread.sender.avatar];
        [self.imvLetter setImage:[UIImage imageNamed:@"received_message_icon"]];
        self.lcTrailingLetterImageView.constant = 8;
    }
    
    if ([self.thread hasNewMessage]) {
        [self setBackgroundColor:GRAY_COLOR];
    }
    else  {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}
@end
