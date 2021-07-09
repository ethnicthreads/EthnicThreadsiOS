//
//  ReadMoreViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ReadMoreViewController.h"

@interface ReadMoreViewController ()
@property (nonatomic, assign) IBOutlet UILabel          *lblTitle;
@property (nonatomic, strong) IBOutlet UITextView       *textView;
@end

@implementation ReadMoreViewController

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
    
    self.textView.text = self.fullText;
    [self.textView setTextColor:[UIColor whiteColor]];
    self.textView.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
    [self.textView becomeFirstResponder];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (IBAction)handleCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
