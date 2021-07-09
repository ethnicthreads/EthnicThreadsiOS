//
//  GenderButton.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/1/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "GenderButton.h"
#import "Constants.h"

@implementation GenderButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.layer.borderColor = UIColorFromRGB(0x959595).CGColor;
    [self setSelected:self.selected];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.imageView.layer.borderWidth = 0;
    }
    else {
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        self.imageView.layer.borderWidth = 0.5;
    }
}
@end
