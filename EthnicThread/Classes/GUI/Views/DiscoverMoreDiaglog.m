//
//  DiscoverMoreDiaglog.m
//  EthnicThread
//
//  Created by DuyLoc on 6/20/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "DiscoverMoreDiaglog.h"
#import "Utils.h"

@interface DiscoverMoreDiaglog ()
@property (weak, nonatomic) IBOutlet UIButton *btnStyles;
@property (weak, nonatomic) IBOutlet UIButton *btnTalent;
@property (weak, nonatomic) IBOutlet UIView *vContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnPeople;
@property (nonatomic, copy) moreDiaglogButtonHandler buttonHandleBlock;
@end
@implementation DiscoverMoreDiaglog

- (instancetype)initWithBlock:(moreDiaglogButtonHandler)buttonHandlerBlock {
    self = [[[UINib nibWithNibName:NSStringFromClass([DiscoverMoreDiaglog class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    [self.btnStyles setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [self.btnPeople setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [self.btnTalent setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    [self.btnStyles setUserInteractionEnabled:YES];
    [self.btnClose setUserInteractionEnabled:YES];
    self.buttonHandleBlock = buttonHandlerBlock;
    return self;
}

- (void)initComponentUI {
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [touches anyObject];
    if (firstTouch.view != self.vContainer) {
        [self dismissView];
    }
}

- (void)dismissView {
    [self removeFromSuperview];
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    [Utils addFitConstraintToView:view subView:self];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissView];
}

- (IBAction)didTapStyle:(id)sender {
    self.buttonHandleBlock(self, @"Style");
}

- (IBAction)didTapTalents:(id)sender {
    self.buttonHandleBlock(self, @"Talent");
}
- (IBAction)didTapPeople:(id)sender {
    self.buttonHandleBlock(self, @"People");
}

@end
