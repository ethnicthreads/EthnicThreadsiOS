//
//  DiscoverMoreDiaglog.h
//  EthnicThread
//
//  Created by DuyLoc on 6/20/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@interface DiscoverAllDiaglog : BaseView
typedef void(^allDiaglogButtonHandler)(DiscoverAllDiaglog *moreDiaglog, NSString *title);
- (instancetype)initWithBlock:(allDiaglogButtonHandler)buttonHandlerBlock;
- (void)showInView:(UIView *)view;
@end

