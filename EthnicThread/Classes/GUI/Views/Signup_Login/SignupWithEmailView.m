//
//  SignupWithEmailView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SignupWithEmailView.h"
#import "LoginWithEmailView.h"
#import "ForgotPasswordView.h"

@interface SignupWithEmailView() <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UITextField          *tfEmail;
@property (nonatomic, assign) IBOutlet UITextField          *tfPassword;
@property (nonatomic, assign) IBOutlet UITextField          *tfFirstName;
@property (nonatomic, assign) IBOutlet UITextField          *tfLastName;
@property (nonatomic, assign) IBOutlet UIButton             *btnSignup;
@property (nonatomic, assign) IBOutlet UIView               *containView;

- (IBAction)handleSignupButton:(id)sender;
@end

@implementation SignupWithEmailView

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
- (IBAction)handleSignupButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(startSignup:andPassword:andFirstName:andLastName:)]) {
        [self.delegate startSignup:self.tfEmail.text
                       andPassword:self.tfPassword.text
                      andFirstName:self.tfFirstName.text
                       andLastName:self.tfLastName.text];
    }
}

#pragma mark - AccountProtocol
- (void)showKeyboard {
    [self.tfEmail becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.tfEmail resignFirstResponder];
    [self.tfPassword resignFirstResponder];
    [self.tfFirstName resignFirstResponder];
    [self.tfLastName resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfEmail) {
        [self.tfPassword becomeFirstResponder];
    }
    else if (textField == self.tfPassword) {
        [self.tfFirstName becomeFirstResponder];
    }
    else if (textField == self.tfFirstName) {
        [self.tfLastName becomeFirstResponder];
    }
    else if (textField == self.tfLastName) {
        [self.tfEmail resignFirstResponder];
        [self.tfPassword resignFirstResponder];
        [self.tfFirstName resignFirstResponder];
        [self.tfLastName resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return ![Utils checkEmojiLanguage:[[textField textInputMode] primaryLanguage]];
}
@end
