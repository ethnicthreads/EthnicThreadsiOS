//
//  InviteFriendViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "AvatarButton.h"
#import "CustomImageView.h"
#import "ETActivityItemProvider.h"

@interface InviteFriendViewController () <SlideNavigationControllerDelegate>
@property (nonatomic, assign) IBOutlet CustomImageView      *imvThumb;
@property (nonatomic, assign) IBOutlet UILabel              *lblNoImage;
@property (nonatomic, assign) IBOutlet UILabel              *lblName;
@property (nonatomic, assign) IBOutlet UILabel              *lblLocation;
@property (nonatomic, assign) IBOutlet UITextView           *tvLink;
@end

@implementation InviteFriendViewController

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
    [self setNavigationBarTitle:NSLocalizedString(@"invite_friends", @"") andTextColor:BLACK_COLOR_TEXT];
    if (self.canBackToMainMenu) {
        [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:CGRectMake(15, 5, 40, 50)];
    }
    else {
        [self setLeftNavigationItem:@""
                       andTextColor:nil
                     andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                           andFrame:CGRectMake(0, 0, 40, 35)];
    }
    
    [self.imvThumb setContentMode:UIViewContentModeScaleAspectFit];
    AccountModel *account = [[UserManager sharedInstance] getAccount];
    [self.imvThumb loadImageForUrl:account.avatar type:IMAGE_DONOTHING];
    [self.lblNoImage setHidden:(account.avatar.length > 0)];
    self.tvLink.text = APP_LINK;//[NSString stringWithFormat:@"%@%@", PROFILE_LINK, [account getIdString]];

    self.lblName.text = [account getDisplayName];
    self.lblLocation.text = [account getLocation];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    if (self.canBackToMainMenu) {
        [self handleTouchToMainMenuButton];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)handleShareLinkButton:(id)sender {
    [[AppManager sharedInstance] inviteFriendsToUseAppWithMessage:self.tvLink.text viewController:self];
}

- (IBAction)handlerShareThisApp:(id)sender {
    [[AppManager sharedInstance] shareThisApp:self];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return self.canBackToMainMenu;
}
@end
