//
//  FaqViewController.m
//  EthnicThread
//
//  Created by PhuocDuy on 4/18/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "FaqViewController.h"

@interface FaqViewController () <SlideNavigationControllerDelegate, UIWebViewDelegate>
@property (nonatomic, assign) IBOutlet UIWebView    *webView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *indicator;
@end

@implementation FaqViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:NSLocalizedString(@"faq", @"") andTextColor:BLACK_COLOR_TEXT];
    CGRect rect = CGRectMake(15, 5, 40, 50);
    [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:rect];
    
    NSString *url = FAQ_URL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self handleTouchToMainMenuButton];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
    [self.indicator setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}
@end
