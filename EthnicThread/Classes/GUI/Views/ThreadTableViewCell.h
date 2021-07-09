//
//  ThreadTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadModel.h"
#import "SWTableViewCell.h"

@interface ThreadTableViewCell : SWTableViewCell
@property (nonatomic, strong) ThreadModel      *thread;
@end
