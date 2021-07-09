//
//  ChangePasswordViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface ChangePasswordViewController () <UITextFieldDelegate, TPKeyboardProtocol>
@property (nonatomic, assign) IBOutlet TPKeyboardAvoidingScrollView     *scvAvoiding;
@property (nonatomic, assign) IBOutlet UITextField      *tfOldPassword;
@property (nonatomic, assign) IBOutlet UITextField      *tfNewPassword;
@property (nonatomic, assign) IBOutlet UITextField      *tfConfirmPassword;
@property (nonatomic, assign) IBOutlet UIButton         *btnCancel;
@property (nonatomic, assign) IBOutlet UIButton         *btnOK;
@property (nonatomic, assign) IBOutlet UIView           *containView;
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    self.containView.layer.cornerRadius = 3;
    [self.tfOldPassword becomeFirstResponder];
    self.scvAvoiding.tpDelegate = self;
}

- (IBAction)handleCancelButton:(id)sender {
    [self.tfOldPassword resignFirstResponder];
    [self.tfNewPassword resignFirstResponder];
    [self.tfConfirmPassword resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(closeChangePasswordView)]) {
        [self.delegate closeChangePasswordView];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleOKButton:(id)sender {
    NSString *mess = nil;
    if (![self.tfOldPassword.text isEqualToString:[[UserManager sharedInstance] getAccount].password]) {
        mess = NSLocalizedString(@"alert_enter_incorrect_old_password", @"");
    }
    else if (self.tfNewPassword.text.length < 8) {
        mess = NSLocalizedString(@"alert_incorect_format_password", @"");
    }
    else if ([self.tfNewPassword.text isEqualToString:self.tfOldPassword.text]) {
        mess = NSLocalizedString(@"alert_new_password_different_old_one", @"");
    }
    else if (![self.tfNewPassword.text isEqualToString:self.tfConfirmPassword.text]) {
        mess = NSLocalizedString(@"alert_enter_not_match_password", @"");
    }
    
    if (mess) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_sorry", @"")
                                                        message:mess
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_ok", @"")
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.tfOldPassword.text forKey:@"currentPassword"];
    [dict setObject:self.tfNewPassword.text forKey:@"password"];
    [dict setObject:self.tfConfirmPassword.text forKey:@"passwordConfirmation"];
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateUserProfile:threadObj:) argument:dict];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWasShown:(NSNotification *)noti {
    [self.scvAvoiding setScrollEnabled:NO];
}

- (void)executeUpdateUserProfile:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager updateUserProfile:[[[UserManager sharedInstance] getAccount] getIdString]
                                            andFormValue:param];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response.getJsonObject];
        if ([param objectForKey:@"password"]) {
            [dict setObject:[param objectForKey:@"password"] forKey:@"password"];
        }
        UserManager *userManager = [UserManager sharedInstance];
        [userManager updateValueWithDictionary:dict
                                andLoginStatus:[dict objectForKey:@"facebook_account"] ? FACEBOOK_LOGIN : EMAIL_LOGIN];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tfOldPassword resignFirstResponder];
            [self.tfNewPassword resignFirstResponder];
            [self.tfConfirmPassword resignFirstResponder];
            
            if ([self.delegate respondsToSelector:@selector(changePasswordSuccess:)]) {
                [self.delegate changePasswordSuccess:self.tfNewPassword.text];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

#pragma mark - TPKeyboardProtocol
- (void)tpKeyboardDidFinishEditing:(id)editingField {
    [self.scvAvoiding setScrollEnabled:YES];
}

- (void)tpKeyboardDidTouchOnView:(id)aView {
    [self handleCancelButton:self.btnCancel];
}
@end
