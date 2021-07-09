//
//  InvocationThread.h
//  REP
//
//  Created by Phan Nam on 8/1/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OperationProtocol <NSObject>

- (BOOL)isCancelled;
- (void)cancel;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (BOOL)isReady;
- (void)releaseOperation;
@end

@interface InvocationThread : NSObject <OperationProtocol>
@property (strong, nonatomic) NSInvocationOperation    *invocationOperation;
@end

