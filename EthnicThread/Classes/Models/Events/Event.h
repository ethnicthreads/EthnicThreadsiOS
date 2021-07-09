//
//  Event.h
//  Saleshood
//
//  Created by Phan Nam on 8/7/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Event : NSObject
@property (nonatomic, assign) CHANNELS          channel;
@property (nonatomic, assign) EVENTTYPE         eventType;
@property (nonatomic, strong) NSDictionary      *result;
@property (nonatomic, strong) NSError           *error;
@property (nonatomic, assign) int               et;
- (id)initWithEvenType:(EVENTTYPE)eventType result:(NSDictionary *)result channel:(CHANNELS)channel;
@end
