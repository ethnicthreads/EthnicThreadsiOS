//
//  EventManager.m
//  Ethnic
//
//  Created by Phan Nam on 8/7/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "EventManager.h"

@implementation EventManager

/**
 * create singleton instance for device manager
 */
+ (EventManager *)shareInstance {
    static EventManager *eventManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventManager = [[EventManager alloc] init];
    });
	return eventManager;
}

- (id)init {
    if (self = [super init]) {
        dictChannel = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	return self;
}

#pragma mark - PUBLIC METHODS
- (void)addListener:(id)listener channel:(CHANNELS)channel {
    @synchronized(self) {
        NSString *key = [self keyForChannel:channel];
        NSMutableArray *array = [dictChannel objectForKey:key];
        if (array == nil) {
            [dictChannel setObject:[NSMutableArray array] forKey:key];
            array = [dictChannel objectForKey:key];
        }
        if (![array containsObject:listener]) {
            [array addObject:listener];
        }
    }
}

- (void)removeListener:(id)listener channel:(CHANNELS)channel {
    @synchronized(self) {
        NSMutableArray *array = [dictChannel objectForKey:[self keyForChannel:channel]];
        [array removeObject:listener];
    }
}

- (void)removeListenerInAllChannels:(id)listener {
    @synchronized(self) {
        NSArray *arrays = [dictChannel allValues];
        for (NSMutableArray *channels in arrays) {
            if ([channels containsObject:listener]) {
                [channels removeObject:listener];
            }
        }
    }
}

- (void)callbackToChannel:(CHANNELS)channel event:(Event *)event {
    NSMutableArray *array = [dictChannel objectForKey:[self keyForChannel:channel]];
    event.channel = channel;
    if (array) {
        NSArray *objects = [NSArray arrayWithArray:array];
        for (id delegate in objects) {
            if ([delegate respondsToSelector:@selector(dispatchChannelEvent:)]) {
                [delegate dispatchChannelEvent:event];
            }
        }
    }
}

#pragma mark - Private api
- (NSString *)keyForChannel:(CHANNELS)channel {
    NSString *str;
    switch (channel) {
        case CHANNEL_UI:
            str = @"CHANNEL_UI";
            break;
        case CHANNEL_DATA:
            str = @"CHANNEL_DATA";
            break;
        default:
            str = @"UNKNOWN";
            break;
    }
    return str;
}

- (void)fireEventWithType:(EVENTTYPE)type result:(NSDictionary *)result channel:(CHANNELS)channel {
    if (channel == CHANNEL_UI) {
        if ([NSThread isMainThread]) {
            Event *event = [[Event alloc] initWithEvenType:type result:result channel:channel];
            [[EventManager shareInstance] callbackToChannel:channel event:event];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self fireEventWithType:type result:result channel:channel];
            });
        }
    }
    else {
        Event *event = [[Event alloc] initWithEvenType:type result:result channel:channel];
        [[EventManager shareInstance] callbackToChannel:channel event:event];
    }
}


@end
