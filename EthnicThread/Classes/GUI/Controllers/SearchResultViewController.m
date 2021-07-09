//
//  SearchResultViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SearchResultViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchResultViewController()
@property (nonatomic, assign) IBOutlet UILabel *lbNoResult;
@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initVariables {
    [super initVariables];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"search_results", @"") andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    
    [self.view setBackgroundColor:LIGHT_GRAY_COLOR];
    [self.lbNoResult setHidden:YES];
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handlerRightNavigationItem:(id)sender {
    [super handlerRightNavigationItem:sender];
}

- (Response *)connectToServerToGetItems {
    return [CloudManager searchItems:self.criteria andFromPage:self.downLoadingPage andPer:PER_COUNT];
}

- (void)downloadLatestItemsCompleted:(BOOL)itemCount {
    [self.lbNoResult setHidden:(itemCount != 0)];
    [self.tableView setHidden:(itemCount == 0)];
    if (itemCount == 0) {
        if (self.criteria.radius == 0) {
            self.lbNoResult.text = NSLocalizedString(@"no_results_search_anywhere", @"");
        }
        else {
            self.lbNoResult.text = [NSString stringWithFormat:NSLocalizedString(@"no_results_within_x_mile", @""), self.criteria.radius, (self.criteria.radius == 1) ? @"mile" : @"miles"];
        }
    }
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return NO;
}
@end
