//
//  TagTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/16/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "TagTableViewCell.h"

@interface TagTableViewCell()

@end

@implementation TagTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)handleCheckButton:(id)sender {
    self.btnCheck.selected = !self.btnCheck.selected;
    if ([self.delegate respondsToSelector:@selector(updateTagStatus:)]) {
        [self.delegate updateTagStatus:self];
    }
}
@end
