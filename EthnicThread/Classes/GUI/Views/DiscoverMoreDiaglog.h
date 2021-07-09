//
//  DiscoverMoreDiaglog.h
//  EthnicThread
//
//  Created by DuyLoc on 6/20/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@interface DiscoverMoreDiaglog : BaseView
typedef void(^moreDiaglogButtonHandler)(DiscoverMoreDiaglog *moreDiaglog, NSString *title);
- (instancetype)initWithBlock:(moreDiaglogButtonHandler)buttonHandlerBlock;
- (void)showInView:(UIView *)view;
@end

