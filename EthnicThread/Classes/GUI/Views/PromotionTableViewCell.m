//
//  PromotionTableViewCell.m
//  EthnicThread
//
//  Created by DuyLoc on 10/18/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "PromotionTableViewCell.h"
#import "Constants.h"

@implementation PromotionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        self.btnTitle.titleLabel.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
        [self.btnTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.btnTitle.titleLabel.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
        [self.btnTitle setTitleColor:GRAY_COLOR forState:UIControlStateNormal];
    }
}

@end
