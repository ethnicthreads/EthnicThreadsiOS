//
//  LocationDiscoverView.m
//  EthnicThread
//
//  Created by DuyLoc on 6/7/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "LocationDiscoverView.h"
#import "PPLabel.h"


@interface LocationDiscoverView () <PPLabelDelegate>
@property (weak, nonatomic) IBOutlet PPLabel *lblLocationOff;
@property (nonatomic, copy) didTapButtonWithTitle handleBlock;
@property (weak, nonatomic) IBOutlet UIButton *btnCountrySelector;

@property (weak, nonatomic) IBOutlet UILabel *lblNoResult;
@end

@implementation LocationDiscoverView
- (instancetype)initWithBlock:(didTapButtonWithTitle)buttonHandlerBlock {
    self = [[[UINib nibWithNibName:NSStringFromClass([LocationDiscoverView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    [self.btnCountrySelector.layer setBorderWidth:1.0f];
    [self.btnCountrySelector setBackgroundColor:PURPLE_COLOR];
    [self.btnCountrySelector setTintColor:LIGHT_GRAY_COLOR];
    [self.btnCountrySelector.layer setBorderColor:LIGHT_GRAY_COLOR.CGColor];
    self.lblLocationOff.delegate = self;
    self.handleBlock = buttonHandlerBlock;
    [self.lblNoResult setText:NSLocalizedString(@"no_item_results_setting", @"")];
    return self;
}

- (instancetype)init {
    self = [[[UINib nibWithNibName:NSStringFromClass([LocationDiscoverView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    return self;
}

- (void)shouldShowNoResult:(BOOL)showNoResult {
    [self.lblNoResult setHidden:!showNoResult];
}

- (IBAction)didTapSelectCountry:(id)sender {
    self.handleBlock(self, CountrySelect);
}

- (NSString *)getWordAtIndex:(CFIndex)charIndex string:(NSString *) string{
    if (charIndex == NSNotFound) {
        return @"";
    }
    
    NSRange end = [string rangeOfString:@" " options:0 range:NSMakeRange(charIndex, string.length - charIndex)];
    NSRange start = [string rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, charIndex)];
    
    if (end.location == NSNotFound) {
        end.location = string.length - 1;
    }
    
    if (start.location == NSNotFound) {
        start.location = 0;
    }
    
    NSRange wordRange = NSMakeRange(start.location, end.location - start.location);
    
    return [string substringWithRange:wordRange];
}

- (IBAction)didTapSearchButton:(id)sender {
    self.handleBlock(self, SearchSelect);
}

#pragma mark - PPLableDelegate
- (BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    DLog(@"Get Word:%@",[self getWordAtIndex:charIndex string:label.text]);
    NSString *word = [self getWordAtIndex:charIndex string:label.text];
    if ([@"turn on location" containString:word]) {
        DLog(@"It's the right word to handle:%@", word);
        self.handleBlock(self, TurnOnLocationLabel);
    }
    return NO;
}

- (BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    
    return NO;
}@end
