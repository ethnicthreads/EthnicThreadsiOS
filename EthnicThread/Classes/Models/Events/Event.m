//
//  Event.m
//  Saleshood
//
//  Created by Phan Nam on 8/7/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "Event.h"

@implementation Event

- (id)init {
    if (self = [super init]) {
        _et = ET_UNKNOWN;
    }
    return self;
}

- (id)initWithEvenType:(EVENTTYPE)eventType result:(NSDictionary *)result channel:(CHANNELS)channel {
    self = [super init];
    if (self) {
        _eventType = eventType;
        _result = result;
        _channel = channel;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"channel: %ld\n", (long)_channel];
    if (self.error) {
        [str appendFormat:@"error: %@", [self.error description]];
    }
    else {
        [str appendFormat:@"result: %@", [_result description]];
    }
    return str;
}
@end
