//
//  RightNavigationView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/6/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
@protocol DiscoverRightNavigationViewDelegate <NSObject>

- (void)inviteFriend;
- (void)searchItems;
- (void)openListRemoteNotification;
@end

@interface DiscoverRightNavigationView : BaseView
@property (nonatomic, assign) id <DiscoverRightNavigationViewDelegate>     delegate;

- (void)setBadges:(NSInteger)badge;
- (void)hiddenNotificationIcon:(BOOL)hidden;
@end
