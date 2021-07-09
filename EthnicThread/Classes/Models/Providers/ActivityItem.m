//
//  ActivityItem.m
//  EthnicThread
//
//  Created by Nam Phan on 9/15/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "ActivityItem.h"

@interface ActivityItem()
@property (nonatomic, strong) NSString      *subject;
@property (nonatomic, strong) NSString      *message;
@end

@implementation ActivityItem

- (id)initWithSubject:(NSString *)subject message:(NSString *)message {
    if (self = [super init]) {
        self.subject = subject;
        self.message = message;
    }
    return self;
}

- (NSString *)getSubject {
    return self.subject;
}

- (NSString *)getMessage {
    return self.message;
}
@end
