//
//  SizeButton.m
//  EthnicThread
//
//  Created by PhuocDuy on 4/2/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "SizeButton.h"
#import "Constants.h"

@interface SizeButton()
@property (nonatomic, assign) CALayer *subLayer;
@end

@implementation SizeButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initComponentUI];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initComponentUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat d = 25;
    self.subLayer.frame = CGRectMake((self.frame.size.width - d) / 2, (self.frame.size.height - d) / 2, d, d);
}

- (void)initComponentUI {
    CALayer *sublayer = [CALayer layer];
    sublayer.borderColor = [BLACK_COLOR_TEXT CGColor];
    sublayer.borderWidth = 0;
    sublayer.masksToBounds = YES;
    [self.layer addSublayer:sublayer];
    self.subLayer = sublayer;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.selected) {
        self.subLayer.borderWidth = 0;
        self.subLayer.backgroundColor = [PURPLE_COLOR CGColor];
    }
    else {
        self.subLayer.borderWidth = 0.5;
        self.subLayer.backgroundColor = [[UIColor clearColor] CGColor];
    }
}

@end
