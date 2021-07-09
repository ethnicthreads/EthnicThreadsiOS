//
//  FollowersViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/30/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "FollowersViewController.h"

@interface FollowersViewController () 

@end

@implementation FollowersViewController

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
    NSString *title = NSLocalizedString(@"my_followers", @"");
    if (![self.userModel isMe]) {
        title = [NSString stringWithFormat:@"%@'s %@", [self.userModel getDisplayName], NSLocalizedString(@"followers", @"")];
    }
    [self setNavigationBarTitle:title andTextColor:BLACK_COLOR_TEXT];
    
    if (self.canBackToMainMenu) {
        [self setLeftNavigationItem:@"" andTextColor:nil andButtonImage:[UIImage imageNamed:@"purple_menu"] andFrame:CGRectMake(15, 5, 40, 50)];
    }
    else {
        [self setLeftNavigationItem:@""
                       andTextColor:nil
                     andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                           andFrame:CGRectMake(0, 0, 40, 35)];
    }
}

- (Response *)connectToServer {
    return [CloudManager getMyFollowers:[self.userModel getIdString] andFromPage:self.downLoadingPage andPer:USER_PER_COUNT];
}

- (void)handlerLeftNavigationItem:(id)sender {
    if (self.canBackToMainMenu) {
        [self handleTouchToMainMenuButton];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowerTableViewCell *cell = (FollowerTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell allowUnfollow:NO];
    return cell;
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return self.canBackToMainMenu;
}
@end
