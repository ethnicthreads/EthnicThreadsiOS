//
//  PermissionRequestViewController.h
//  EthnicThread
//
//  Created by Nguyen Loc on 11/27/18.
//  Copyright © 2018 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PermissionReuquestDelegate <NSObject>

- (void)didDismissRequestView;

@end

@interface PermissionRequestViewController : BaseViewController
@property (weak, nonatomic) id<PermissionReuquestDelegate> delgate;
@end

NS_ASSUME_NONNULL_END
