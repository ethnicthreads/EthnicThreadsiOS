//
//  PromotionCriteriaCollectionViewCell.m
//  EthnicThread
//
//  Created by DuyLoc on 5/14/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "PromotionCriteriaCollectionViewCell.h"

@interface PromotionCriteriaCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *btnTitle;

@end
@implementation PromotionCriteriaCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.btnTitle setTintColor:GRAY_COLOR];
    [self.btnTitle.titleLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        [self.btnTitle setTintColor:[UIColor whiteColor]];
        [self.btnTitle.titleLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE weight:0.1]];
    } else {
        [self.btnTitle setTintColor:GRAY_COLOR];
        [self.btnTitle.titleLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
    }
}


- (IBAction)didTouchButton:(id)sender {
    DLog(@"Touch Button")
}

- (void)setPromotionCriteria:(PromotionCriteria *)promotionCriteria {
    _promotionCriteria = promotionCriteria;
    [self.btnTitle setTitle:promotionCriteria.displayText.uppercaseString forState:UIControlStateNormal];
//    [self.lblTitile setPreferredMaxLayoutWidth:50];
}

@end
