//
//  RightNavigationView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/6/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "DiscoverRightNavigationView.h"

@interface DiscoverRightNavigationView()
@property (nonatomic, assign) IBOutlet UILabel  *lblBadges;
@property (nonatomic, assign) IBOutlet UIButton *btnNotif;
@property (nonatomic, assign) NSInteger         badge;
@end

@implementation DiscoverRightNavigationView

- (void)initGUI {
    [super initGUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.lblBadges.layer.cornerRadius = self.lblBadges.frame.size.height / 2;
    self.lblBadges.layer.masksToBounds = YES;
    [self.lblBadges setHidden:(self.badge == 0)];
}

- (IBAction)handleInviteFriendButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inviteFriend)]) {
        [self.delegate inviteFriend];
    }
}

- (IBAction)handleSearchItemsButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchItems)]) {
        [self.delegate searchItems];
    }
}

- (IBAction)handleNotificationButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openListRemoteNotification)]) {
        [self.delegate openListRemoteNotification];
    }
}

- (void)setBadges:(NSInteger)badge {
    self.badge = badge;
    NSString *text = [NSString stringWithFormat:@"%ld", (long)badge];
    CGRect rect = self.lblBadges.frame;
    CGFloat width = [Utils calculateWidthForString:text withHeight:rect.size.height andFont:self.lblBadges.font] + 4;
    if (width > rect.size.width) {
        rect.origin.x -= (width - rect.size.width);
        rect.size.width = width;
    }
    self.lblBadges.frame = rect;
    self.lblBadges.text = text;
    [self.lblBadges setHidden:(self.badge == 0)];
}

- (void)hiddenNotificationIcon:(BOOL)hidden {
    [self.lblBadges setHidden:(hidden || self.badge == 0)];
    [self.btnNotif setHidden:hidden];
}
@end
