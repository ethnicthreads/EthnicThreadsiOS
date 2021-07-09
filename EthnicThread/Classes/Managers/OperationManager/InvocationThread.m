//
//  InvocationThread.m
//  REP
//
//  Created by Phan Nam on 8/1/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "InvocationThread.h"

@implementation InvocationThread
- (BOOL)isCancelled {
    return [_invocationOperation isCancelled];
}

- (void)cancel {
    [_invocationOperation cancel];
}

- (BOOL)isExecuting {
    return [_invocationOperation isExecuting];
}

- (BOOL)isFinished {
    return [_invocationOperation isFinished];
}

- (BOOL)isReady {
    return [_invocationOperation isReady];
}

- (void)releaseOperation {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.invocationOperation = nil;
    });
}
@end
