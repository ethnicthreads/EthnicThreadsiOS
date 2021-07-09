//
//  LikersViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/22/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "LikersViewController.h"

@interface LikersViewController ()
@end

@implementation LikersViewController

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
    [self setNavigationBarTitle:[NSLocalizedString(@"likers", @"") uppercaseString] andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
}

- (Response *)connectToServer {
    return [CloudManager getLikersByItem:[self.itemModel getIdString] andFromPage:self.downLoadingPage andPer:USER_PER_COUNT];
}

- (void)handlerLeftNavigationItem:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowerTableViewCell *cell = (FollowerTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell allowUnfollow:NO];
    return cell;
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return NO;
}
@end
