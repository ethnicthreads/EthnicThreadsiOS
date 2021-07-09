//
//  EventManager.h
//  Ethnic
//
//  Created by Phan Nam on 8/7/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Event.h"
#import "ChannelProtocol.h"

@interface EventManager : NSObject {
    NSMutableDictionary         *dictChannel;
}

/**
 * create singleton instance for event manager
 */
+ (EventManager *)shareInstance;

/**
 * add listener for upnp discovery device
 */
- (void)addListener:(id)listener channel:(CHANNELS)channel;
/**
 *	remove listen
 */
- (void)removeListener:(id)listener channel:(CHANNELS)channel;
- (void)removeListenerInAllChannels:(id)listener;
/**
 *	Call back to UI
 */
- (void)callbackToChannel:(CHANNELS)channel event:(Event *)event;

- (void)fireEventWithType:(EVENTTYPE)type result:(NSDictionary *)result channel:(CHANNELS)channel;
@end
