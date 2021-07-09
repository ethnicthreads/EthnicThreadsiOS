//
//  AddItemFinishViewController.m
//  EthnicThread
//
//  Created by Katori on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AddItemFinishViewController.h"
#import "AddItemRequitedViewController.h"
#import "CreativeItemModel.h"
#import "MenuViewController.h"

@interface AddItemFinishViewController ()
@property (nonatomic, assign) IBOutlet UIButton         *btnTellFollower;
@end

@implementation AddItemFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleTellAllFollowers:(id)sender {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeNotifyToAllFollowers:threadObj:) argument:self.itemId];
}

- (IBAction)handleAddNew:(id)sender {
    AddItemRequitedViewController *vc = [[AddItemRequitedViewController alloc] init];
    vc.createdItem = [[CreativeItemModel alloc] init];
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                          withSlideOutAnimation:YES
                                                                  andCompletion:nil];
}

- (IBAction)handleBackDiscoverPage:(id)sender {
    MenuViewController *menuVc = (MenuViewController *)[self getMenuViewController];
    menuVc.discoverVC.shouldRefreshItems = ITEMS_GETNEW;
    [menuVc openDiscoverPage:nil];
}

- (void)executeNotifyToAllFollowers:(NSString *)itemId threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager notifyToAllFollowers:itemId];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.btnTellFollower setEnabled:NO];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}
@end
