//
//  OperationManager.h
//  REP
//
//  Created by Phan Nam on 8/1/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InvocationThread.h"

@interface OperationManager : NSObject
+ (OperationManager *)shareInstance;
- (id<OperationProtocol>)dispatchNormalThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument;
- (id<OperationProtocol>)dispatchLowThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument;
- (id<OperationProtocol>)dispatchLowThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument queue:(NSOperationQueue *)aQueue;
- (void)cancelAllThreadsInTarget:(id)target;
- (void)cancelAndRemoveThreadsInTarget:(id)target;
- (void)stopAllThreads;
@end
