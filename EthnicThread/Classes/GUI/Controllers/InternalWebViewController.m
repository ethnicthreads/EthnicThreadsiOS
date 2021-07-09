//
//  InternalWebViewController.m
//  EthnicThread
//
//  Created by PhuocDuy on 6/15/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "InternalWebViewController.h"

@interface InternalWebViewController () <UIWebViewDelegate>
@property (nonatomic, assign) IBOutlet UIView       *vTopBar;
@property (nonatomic, assign) IBOutlet UILabel      *lblPageTitle;
@property (nonatomic, assign) IBOutlet UIWebView    *webView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *indicator;
@end

@implementation InternalWebViewController

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
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    layer.frame = CGRectMake(0, 64 - 0.75, [UIScreen mainScreen].bounds.size.width, 0.75);
    [self.vTopBar.layer addSublayer:layer];
    
    self.lblPageTitle.text = self.pageTitle;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

- (IBAction)handleDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
    [self.indicator setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *url = webView.request.URL.absoluteString;
    NSRegularExpression *itemRegex = [[NSRegularExpression alloc] initWithPattern:@"/items/\\d*" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *userRegex = [[NSRegularExpression alloc] initWithPattern:@"/users/\\d*" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *itemResult = [itemRegex firstMatchInString:url options:NSMatchingWithTransparentBounds range:NSMakeRange(0, url.length)];
    NSTextCheckingResult *userResult = [userRegex firstMatchInString:url options:NSMatchingWithTransparentBounds range:NSMakeRange(0, url.length)];
    
    if (itemResult) {
        NSString *itemId = [self getIdFromUrl:[url substringWithRange:itemResult.range]];
        if (itemId.length > 0) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[EventManager shareInstance] fireEventWithType:ET_OPEN_ITEM result:[NSDictionary dictionaryWithObject:itemId forKey:ID_KEY] channel:CHANNEL_UI];
            }];
        }
    }
    
    if (userResult) {
        NSString *userId = [self getIdFromUrl:[url substringWithRange:userResult.range]];
        if (userId.length > 0) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[EventManager shareInstance] fireEventWithType:ET_OPEN_SELLER result:[NSDictionary dictionaryWithObject:userId forKey:ID_KEY] channel:CHANNEL_UI];
            }];
        }
    }
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
}

- (NSString *)getIdFromUrl:(NSString *)urlString {
    NSRegularExpression *numberRegex = [[NSRegularExpression alloc] initWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [numberRegex firstMatchInString:urlString options:NSMatchingWithTransparentBounds range:NSMakeRange(0, urlString.length)];
    if (result) {
        return [urlString substringWithRange:result.range];
    }
    return @"";
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
}

@end
