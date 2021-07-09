//
//  ChannelProtocol.h
//  Saleshood
//
//  Created by Phan Nam on 8/7/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;
@protocol ChannelProtocol <NSObject>
@optional
- (void)dispatchChannelEvent:(Event *)aEvent;
@end
