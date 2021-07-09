//
//  LoginWithEmailView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "LoginWithEmailView.h"
#import "ForgotPasswordView.h"

@interface LoginWithEmailView() <UITextFieldDelegate>
@property (nonatomic, assign) IBOutlet UIButton             *btnForgotPassword;
@property (nonatomic, assign) IBOutlet UITextField          *tfEmail;
@property (nonatomic, assign) IBOutlet UITextField          *tfPassword;
@property (nonatomic, assign) IBOutlet UIButton             *btnLogin;
@property (nonatomic, assign) IBOutlet UIView               *containView;
@property (nonatomic, assign) IBOutlet UIButton             *btnRememberMe;

- (IBAction)handleForgotPasswordButton:(id)sender;
- (IBAction)handleLoginButton:(id)sender;
@end
@implementation LoginWithEmailView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.containView.layer.cornerRadius = 3;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.tfEmail becomeFirstResponder];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.tfEmail.text = [userDefaults objectForKey:@"remember_email"];
    self.tfPassword.text = [userDefaults objectForKey:@"remember_password"];
    self.btnRememberMe.selected = [[userDefaults objectForKey:@"remember_check"] boolValue];
}

#pragma mark -
- (IBAction)handleForgotPasswordButton:(id)sender {
    self.lblTitle.text = NSLocalizedString(@"forgot_password", @"");
    UINib *nib = [UINib nibWithNibName:@"ForgotPasswordView" bundle:nil];
    ForgotPasswordView *view = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    view.delegate = self.delegate;
    UIView *lastView = [[[self superview] subviews] lastObject];
    if (lastView) {
        [lastView setHidden:YES];
    }
    [[self superview] addSubview:view];
}

- (IBAction)handleLoginButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(startLogin:andPassword:)]) {
        [self.delegate startLogin:self.tfEmail.text
                       andPassword:self.tfPassword.text];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.btnRememberMe.selected) {
        [userDefaults setObject:self.tfEmail.text forKey:@"remember_email"];
        [userDefaults setObject:self.tfPassword.text forKey:@"remember_password"];
    }
    else {
        [userDefaults setObject:@"" forKey:@"remember_email"];
        [userDefaults setObject:@"" forKey:@"remember_password"];
    }
    [userDefaults setObject:@(self.btnRememberMe.selected) forKey:@"remember_check"];
    [userDefaults synchronize];
}

- (IBAction)handleRememberMeButton:(id)sender {
    self.btnRememberMe.selected = !self.btnRememberMe.selected;
}

#pragma mark - AccountProtocol
- (void)showKeyboard {
    [self.tfEmail becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.tfEmail resignFirstResponder];
    [self.tfPassword resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfEmail) {
        [self.tfPassword becomeFirstResponder];
    }
    else if (textField == self.tfPassword) {
        [self.tfEmail resignFirstResponder];
        [self.tfPassword resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return ![Utils checkEmojiLanguage:[[textField textInputMode] primaryLanguage]];
}
@end
