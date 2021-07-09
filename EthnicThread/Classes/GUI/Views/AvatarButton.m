//
//  AvatarButton.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/1/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AvatarButton.h"
#import "Constants.h"
#import "Categories.h"
#import "UIButton+Custom.h"

@implementation AvatarButton

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
    [self displayDefaultImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.layer.masksToBounds = YES;
}

- (void)boderWidth:(CGFloat)width andColor:(CGColorRef)color {
    self.layer.borderColor = color;
    self.layer.borderWidth = width;
}

- (void)displayDefaultImage {
    [self setBackgroundImage:[UIImage imageNamed:USER_THUMB] forState:UIControlStateNormal];
}

//- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
//    if (image) {
//        UIImage *croptImage = [image cropCenterToSize:CGSizeMake(image.size.width, image.size.width)];
//        [super setBackgroundImage:croptImage forState:state];
//    }
//}
//
//- (void)setImage:(UIImage *)image {
//    [self setBackgroundImage:image forState:UIControlStateNormal];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
