//
//  LocationDiscoverView.h
//  EthnicThread
//
//  Created by DuyLoc on 6/7/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

#define TurnOnLocationLabel @"TurnOnLocation"
#define CountrySelect @"CountrySelect"
#define SearchSelect @"SearchSelect"

@interface LocationDiscoverView : BaseView
typedef void(^didTapButtonWithTitle)(LocationDiscoverView *locationView, NSString *title);
- (instancetype)initWithBlock:(didTapButtonWithTitle)buttonHandlerBlock;
- (void)shouldShowNoResult:(BOOL)showNoResult;
@end
