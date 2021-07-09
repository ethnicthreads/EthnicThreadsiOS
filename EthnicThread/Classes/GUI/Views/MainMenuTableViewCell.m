//
//  MainMenuTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 3/3/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "MainMenuTableViewCell.h"

@interface MainMenuTableViewCell()
@property (nonatomic, strong) IBOutlet UILabel      *lblBadges;
@end

@implementation MainMenuTableViewCell

- (void)awakeFromNib {
    self.lblBadges.layer.cornerRadius = self.lblBadges.frame.size.height / 2;
    self.lblBadges.layer.masksToBounds = YES;
    [self.lblBadges setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBadgesNumber:(NSInteger)badges {
    if (badges == 0) {
        [self.lblBadges setHidden:YES];
    }
    else {
        self.lblBadges.text = (badges < 10) ? [NSString stringWithFormat:@"%ld", (long)badges] : @"9+";
        [self.lblBadges setHidden:NO];
    }
}
@end
