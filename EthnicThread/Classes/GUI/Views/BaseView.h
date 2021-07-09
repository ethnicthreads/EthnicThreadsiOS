//
//  BaseView.h
//  EthnicThread
//
//  Created by Nam Phan on 12/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+Custom.h"
#import "OperationManager.h"
#import "CloudManager.h"
#import "DownloadManager.h"
#import "CachedManager.h"
#import "EventManager.h"
#import "AppManager.h"
#import "UserManager.h"
#import "Utils.h"
#import "Categories.h"
#import "Constants.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIView+AutoLayout.h"

@interface BaseView : UIView {
    CGFloat viewHeight;
}
@property (nonatomic, strong) id<OperationProtocol>     asyncThread;
- (void)stopAllThreads;
- (void)initVariables;
- (void)initGUI;
- (void)layoutComponents;
- (void)didLoadGUI;
- (CGFloat)getHeightOfView;
- (void)updateContraintAndRenderScreenIfNeeded;
@end
