//
//  SignupViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SignupViewController.h"
#import "SignupWithEmailView.h"
#import "LoginWithEmailView.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "InternalWebViewController.h"
#import <FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SignupViewController () <UserAuthortyDelegate, SlideNavigationControllerDelegate, UIAlertViewDelegate> {
    BOOL openingActiveSessionOfFacebook;
}

@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidth;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeight;

@property (nonatomic, assign) IBOutlet UIButton             *btnFBLoginView;
@property (nonatomic, assign) IBOutlet UIButton             *btnBack;
@property (nonatomic, assign) IBOutlet UIButton             *btnClose;
@property (nonatomic, assign) IBOutlet UIButton             *btnSignUpWithEmail;
@property (nonatomic, assign) IBOutlet UIButton             *btnLoginWithEmail;
@property (nonatomic, assign) IBOutlet UIView               *containSubview;
@property (nonatomic, assign) IBOutlet UIView               *bottomView;
@property (nonatomic, assign) IBOutlet UILabel              *lblTitle;
@property (nonatomic, assign) IBOutlet UILabel              *lblAppName;
@property (nonatomic, assign) IBOutlet UILabel              *lblTerms;
@property (nonatomic, assign) IBOutlet UIButton             *btnTerms;

@property (nonatomic, strong) SignupWithEmailView           *signupView;
@property (nonatomic, strong) LoginWithEmailView            *loginView;
@property (nonatomic, assign) id <NSObject>                 notificationObserver;
@property (nonatomic, assign) id<OperationProtocol>         runningThread;

- (IBAction)handleBackButton:(id)sender;
- (IBAction)handleCloseButton:(id)sender;
- (IBAction)handleFBLoginButton:(id)sender;
- (IBAction)handleSignUpWithEmailButton:(id)sender;
- (IBAction)handleLoginWithEmailButton:(id)sender;
@end

@implementation SignupViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _signupView = [[[UINib nibWithNibName:@"SignupWithEmailView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.signupView.delegate = self;
    
    _loginView = [[[UINib nibWithNibName:@"LoginWithEmailView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.loginView.delegate = self;
}

- (void)updateViewConstraints {
    self.lcWidth.constant = [UIScreen mainScreen].bounds.size.width;
    self.lcHeight.constant = [UIScreen mainScreen].bounds.size.height;
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initComponentUI {
    [super initComponentUI];
    
    self.lblTitle.text = @"";
    [self.btnBack setHidden:YES];
    
    self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification *note) {
                                                                                  if (openingActiveSessionOfFacebook) {
                                                                                      [self startSpinnerWithWaitingText];
                                                                                  }
                                                                              }];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"terms_of_services", @"")];
    [attributedString addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                             range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0xececec)
                             range:NSMakeRange(0, attributedString.length)];
    [self.btnTerms setAttributedTitle:attributedString forState:UIControlStateNormal];
    [self.lblTerms setTextColor:UIColorFromRGB(0xececec)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private Method
- (void)stayInRootView:(BOOL)isRoot {
    [self.bottomView setHidden:!isRoot];
    [self.btnBack setHidden:isRoot];
    [self.lblAppName setHidden:!isRoot];
}

- (void)executeLoginByEmail:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager logInViaEmail:[param objectForKey:@"username_email"]
                                         andPassword:[param objectForKey:@"password"]];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response.getJsonObject];
        [dict setObject:[param objectForKey:@"password"] forKey:@"password"];
        [[UserManager sharedInstance] updateValueWithDictionary:dict andLoginStatus:EMAIL_LOGIN];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self loginSuccessfully];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeSignupViaEmail:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager signUpViaEmail:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:response.getJsonObject];
        [dict setObject:[param objectForKey:@"password"] forKey:@"password"];
        [[UserManager sharedInstance] updateValueWithDictionary:dict andLoginStatus:EMAIL_LOGIN];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self signUpSuccessfully];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
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
            
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}


- (void)executeLoginViaFacebook:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager logInViaFacebook:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        [[UserManager sharedInstance] updateValueWithDictionary:response.getJsonObject andLoginStatus:FACEBOOK_LOGIN];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([[UserManager sharedInstance] getAccount].sign_in_count == 1) {
                [self signUpSuccessfully];
            }
            else {
                [self loginSuccessfully];
            }
        });
    }
    else {
        [self clearFBCache];
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)clearFBCache {
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    [[[FBSDKLoginManager alloc] init] logOut];
}

- (void)executeResetPassword:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager resetPassword:body];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_info", @"")
                                                            message:NSLocalizedString(@"alert_reset_password_successfully", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"alert_button_ok", @"")
                                                  otherButtonTitles:nil, nil];
            alert.tag = 11;
            [alert show];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)signUpSuccessfully {
    [self showInviteCode];
}

- (void)showCompleteProfile {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_info", @"")
                                                    message:NSLocalizedString(@"alert_requite_to_complete_profile", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_button_notnow", @"")
                                          otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alert.tag = 10;
    [alert show];
}

- (void)showInviteCode {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"alert_enter_invite_code", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_skip", @"") otherButtonTitles:NSLocalizedString(@"alert_button_ok", @""), nil];
    alert.tag = 20;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *tfCode = [alert textFieldAtIndex:0];
    tfCode.text = [[AppManager sharedInstance] getInvitationCode];
    [alert show];
}

- (void)loginSuccessfully {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate registerForPushNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_LOGIN_NOTIFICATION object:nil userInfo:self.userInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
- (IBAction)handleBackButton:(id)sender {
    UIView *lastView = [[self.containSubview subviews] lastObject];
    if (lastView) {
        [lastView removeFromSuperview];
        id obj = [[self.containSubview subviews] lastObject];
        if ([obj isKindOfClass:[LoginWithEmailView class]]) {
            self.lblTitle.text = NSLocalizedString(@"login", @"");
        }
        if ([obj isKindOfClass:[SignupWithEmailView class]]) {
            self.lblTitle.text = NSLocalizedString(@"signup", @"");
        }
        if (obj && [obj conformsToProtocol:@protocol(AccountProtocol)]) {
            id <AccountProtocol> ptc = obj;
            [ptc showKeyboard];
            [(UIView *)ptc setHidden:NO];
        }
    }
    if ([self.containSubview subviews].count == 0) {
        self.lblTitle.text = @"";
        [self stayInRootView:YES];
    }
    else {
        [self stayInRootView:NO];
    }
}

- (IBAction)handleCloseButton:(id)sender {
    MenuViewController *menuVc = (MenuViewController *)[self getMenuViewController];
    if (menuVc.discoverVC.shouldRefreshItems == ITEMS_UPDATESTATUS) {
        menuVc.discoverVC.shouldRefreshItems = ITEMS_DONOTHING;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleFBLoginButton:(id)sender {
    NSArray *permissions = [NSArray arrayWithObjects:@"email", @"user_photos", @"user_location", @"public_profile", nil];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: permissions
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
            [self requestForMe:error];
         }
     }];
}

- (IBAction)handleTermsButton:(id)sender {
    InternalWebViewController *vc = [[InternalWebViewController alloc] init];
    vc.url = EULA_URL;
    vc.pageTitle = NSLocalizedString(@"terms_of_services", @"");
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)requestForMe:(NSError *)error {
    DLog(@"Run hẻeeeee");
    if ([FBSDKAccessToken currentAccessTokenIsActive]) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"email,first_name,last_name,picture,gender"}];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error1) {
            if (!error && [result isKindOfClass:[NSDictionary class]]) {
                NSString *userImageURL = [NSString stringWithFormat:FACEBOOK_AVATAR_FORMAT_URL, [result objectForKey:@"id"]];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:result];
                [dict setObject:[result objectForKey:@"id"] forKey:@"facebookId"];
                [dict setObject:userImageURL forKey:@"pictureUrl"];
                [dict setObject:[[FBSDKAccessToken currentAccessToken] tokenString] forKey:@"facebookToken"];
                [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeLoginViaFacebook:threadObj:) argument:dict];
                NSLog(@"REsult:%@", dict);
                
            } else {
                [self stopSpinner];
                [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"")
                                               message:NSLocalizedString(@"alert_login_with_fb_failed", @"")];
            }
        }];
    } else {
        //clear cache
        if (error) {
            [self stopSpinner];
            [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"")
                                           message:NSLocalizedString(@"alert_login_with_fb_failed", @"")];
            DLog(@"signInError=%@. Error code: %ld", [error userInfo], (long)[error code]);
        }
        [self clearFBCache];
    }
}

- (IBAction)handleSignUpWithEmailButton:(id)sender {
    self.lblTitle.text = NSLocalizedString(@"signup", @"");
    [self.containSubview addSubview:self.signupView];
    [self stayInRootView:NO];
}

- (IBAction)handleLoginWithEmailButton:(id)sender {
    self.lblTitle.text = NSLocalizedString(@"login", @"");
    self.loginView.lblTitle = self.lblTitle;
    [self.containSubview addSubview:self.loginView];
    [self stayInRootView:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    id obj = [[self.containSubview subviews] lastObject];
    if (obj && [obj conformsToProtocol:@protocol(AccountProtocol)]) {
        id <AccountProtocol> ptc = obj;
        [ptc hideKeyboard];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {//10 alert sign up successfully
        MenuViewController *menuVc = (MenuViewController *)[SlideNavigationController sharedInstance].leftMenu;
        if (buttonIndex == 1) {
            [menuVc openCreateProfilePage];
        }
        else {
            [menuVc openDiscoverPage:nil];
        }
        [self loginSuccessfully];
    }
    if (alertView.tag == 11) {// 11 alert reset password successfully
        if (buttonIndex == 0) {
            [self handleBackButton:self.btnBack];
        }
    }
    if (alertView.tag == 20) { // invite code
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"alert_button_notnow", @"")]) {
            [self showCompleteProfile];
        } else {
            NSString *inviteCode = [alertView textFieldAtIndex:0].text;
            NSDictionary *dict = [[[UserManager sharedInstance] getCreativeAccount] makeDictionary];
            [dict setValue:inviteCode forKey:@"inviteCode"];
//            [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateUserProfile:threadObj:) argument:dict];
            NSString *code = [[AppManager sharedInstance] getInvitationCode];
            if (code.length > 0) {
                [[AppManager sharedInstance] acceptFriendInvitationWithCode:code];
            }
            DLog(@"Update:%@", [alertView textFieldAtIndex:0].text);
            [self showCompleteProfile];
        }
    }
}

#pragma mark - LoginViaFacebookDelegate
- (void)requestServerToLoginFacebookAccount:(NSDictionary *)bodyDict {
    if (![self.runningThread isReady])
        self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeLoginViaFacebook:threadObj:) argument:bodyDict];
}

#pragma mark - UserAuthortyDelegate
- (void)startSignup:(NSString *)email andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:email forKey:@"email"];
    [dict setObject:firstName forKey:@"firstName"];
    [dict setObject:lastName forKey:@"lastName"];
    [dict setObject:password forKey:@"password"];
    [dict setObject:password forKey:@"passwordConfirmation"];
    
    if (![self.runningThread isReady])
        self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeSignupViaEmail:threadObj:) argument:dict];
}

- (void)startLogin:(NSString *)email andPassword:(NSString *)password {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:email forKey:@"username_email"];
    [dict setObject:password forKey:@"password"];
    if (![self.runningThread isReady])
        self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeLoginByEmail:threadObj:) argument:dict];
}

- (void)startResetPassword:(NSString *)email {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email", nil];
    if (![self.runningThread isReady])
        self.runningThread = [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeResetPassword:threadObj:) argument:dict];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return YES;
}
@end
