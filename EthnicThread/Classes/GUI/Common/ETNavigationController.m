//
//  ETNavigationController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/9/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ETNavigationController.h"
#import "BaseViewController.h"

@interface ETNavigationController ()

@end

@implementation ETNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self stopAllThreadsOfViewControllerBeforeQuit:self.topViewController];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *array = [super popToViewController:viewController animated:animated];
    for (UIViewController *viewController in array) {
        [self stopAllThreadsOfViewControllerBeforeQuit:viewController];
    }
    return array;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    for (UIViewController *viewController in array) {
        [self stopAllThreadsOfViewControllerBeforeQuit:viewController];
    }
    return array;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    for (UIViewController *viewController in self.viewControllers) {
        [self stopAllThreadsOfViewControllerBeforeQuit:viewController];
    }
    [super setViewControllers:viewControllers animated:animated];
}

- (void)stopAllThreadsOfViewControllerBeforeQuit:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        [((BaseViewController *) viewController) stopAllThreadsBeforeQuit];
    }
}

@end
