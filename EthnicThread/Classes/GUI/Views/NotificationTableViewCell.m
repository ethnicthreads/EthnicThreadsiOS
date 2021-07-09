//
//  NotificationTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/27/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Constants.h"
#import "DateTimeUtil.h"
#import "AvatarButton.h"
#import "UIButton+Custom.h"

@interface NotificationTableViewCell()
@property (nonatomic, strong) IBOutlet UILabel      *lblBody;
@property (nonatomic, strong) IBOutlet UILabel      *lblMessage;
@property (nonatomic, strong) IBOutlet UILabel      *lblDate;
@property (nonatomic, strong) IBOutlet AvatarButton *btnAvatar;
@end

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setNotif:(NotificationModel *)notif {
    self.lblBody.text = [Utils convertUnicodeToEmoji:notif.alert_body];
    self.lblDate.text = [DateTimeUtil formatFriendlyDuration:[notif getCreatedDate]];
    self.lblMessage.text = [notif getMessage];
    [self.btnAvatar loadImageForUrl:notif.pictureUrl];
    if (notif.dismissed) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [self setBackgroundColor:GRAY_COLOR];
    }
}
@end
