//
//  InputDescViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/17/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "InputDescViewController.h"

@interface InputDescViewController ()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidth;
@property (nonatomic, assign) IBOutlet UILabel          *lblTitle;
@property (nonatomic, strong) IBOutlet UITextView       *textView;
@end

@implementation InputDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    self.lblTitle.text = self.pageTitle;
    
    [self.textView setTextColor:BLACK_COLOR_TEXT];
    self.textView.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
    self.textView.text = self.content;
    [self.textView becomeFirstResponder];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    self.lcWidth.constant = [UIScreen mainScreen].bounds.size.width;
}

- (IBAction)handleOKButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inputComplete:)]) {
        [self.delegate inputComplete:self.textView.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
