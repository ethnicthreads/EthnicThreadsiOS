//
//  ForgotPasswordView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ForgotPasswordView.h"

@interface ForgotPasswordView() <UITextFieldDelegate>
@property (nonatomic, assign) IBOutlet UITextField          *tfEmail;
@property (nonatomic, assign) IBOutlet UIButton             *btnResetPassword;
@property (nonatomic, assign) IBOutlet UIView               *containView;

- (IBAction)handleResetPasswordButton:(id)sender;
@end

@implementation ForgotPasswordView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.containView.layer.cornerRadius = 3;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.tfEmail becomeFirstResponder];
}

#pragma mark -
- (IBAction)handleResetPasswordButton:(id)sender {
    [self.tfEmail resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(startResetPassword:)]) {
        [self.delegate startResetPassword:self.tfEmail.text];
    }
}

#pragma mark - AccountProtocol
- (void)showKeyboard {
    [self.tfEmail becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.tfEmail resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfEmail) {
        [self.tfEmail resignFirstResponder];
        if ([self.delegate respondsToSelector:@selector(startResetPassword:)]) {
            [self.delegate startResetPassword:self.tfEmail.text];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return ![Utils checkEmojiLanguage:[[textField textInputMode] primaryLanguage]];
}
@end
