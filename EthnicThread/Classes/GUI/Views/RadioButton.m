//
//  RadioButton.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/21/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "RadioButton.h"

@interface RadioButton()
@property (nonatomic, strong) UIImageView       *radioImageView;
@end

@implementation RadioButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initComponentUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initComponentUI];
}

- (void)initComponentUI {
    CGRect rect = CGRectMake(5, 0, 13, 13);
    rect.origin.y = self.frame.size.height / 2 - 6.5;
    _radioImageView = [[UIImageView alloc] initWithFrame:rect];
    [self.radioImageView setImage:[UIImage imageNamed:@"radio_unselected"]];
    [self addSubview:self.radioImageView];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTintColor:[UIColor whiteColor]];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.radioImageView setImage:[UIImage imageNamed:@"radio_selected"]];
    }
    else {
        [self.radioImageView setImage:[UIImage imageNamed:@"radio_unselected"]];
    }
}
@end
