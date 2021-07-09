//
//  NotificationTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/27/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"

@interface NotificationTableViewCell : UITableViewCell
@property (nonatomic, strong) NotificationModel     *notif;
@end
