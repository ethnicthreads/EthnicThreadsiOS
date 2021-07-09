//
//  OperationManager.m
//  REP
//
//  Created by Phan Nam on 8/1/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "OperationManager.h"

@interface OperationManager()
@property (strong, nonatomic) NSOperationQueue      *operationQueue;
@property (nonatomic, strong) NSMapTable            *mapTable;
@end

@implementation OperationManager

+ (OperationManager *)shareInstance {
    static OperationManager *instance = nil;
    static dispatch_once_t dispatch_token;
    dispatch_once(&dispatch_token, ^(void) {
        instance = [[OperationManager alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:10];
        _mapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:20];
    }
    return self;
}

- (void)cancelAllThreadsInTarget:(id)target {
    @synchronized(self) {
        [self.mapTable removeObjectForKey:target];
    }
}

- (void)stopAllThreads {
    [self.operationQueue cancelAllOperations];
    [self.mapTable removeAllObjects];
}

- (id<OperationProtocol>)dispatchNormalThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument {
    return [self dispatchThreadWithTarget:target selector:sel argument:argument priority:NSOperationQueuePriorityNormal queue:self.operationQueue];
}

- (id<OperationProtocol>)dispatchLowThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument {
    return [self dispatchThreadWithTarget:target selector:sel argument:argument priority:NSOperationQueuePriorityLow queue:self.operationQueue];
}

- (id<OperationProtocol>)dispatchLowThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument queue:(NSOperationQueue *)aQueue {
    return [self dispatchThreadWithTarget:target selector:sel argument:argument priority:NSOperationQueuePriorityLow queue:aQueue];
}

#pragma mark - Private Method
- (id<OperationProtocol>)dispatchThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument priority:(NSOperationQueuePriority)queuePriority queue:(NSOperationQueue *)aQueue  {
    if (argument == nil || ![target respondsToSelector:sel]) return nil;
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    InvocationThread *invocationThread = [[InvocationThread alloc] init];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    [invocation setArgument:&argument atIndex:2];
    [invocation setArgument:&invocationThread atIndex:3];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [operation setQueuePriority:queuePriority];
    invocationThread.invocationOperation = operation;
    
    //cache thread before adding to operation queue
    [self cacheThread:invocationThread target:target];
    [aQueue addOperation:operation];
    return invocationThread;
}

- (void)cacheThread:(id<OperationProtocol>)thread target:(id)target {
    @synchronized(self) {
        NSHashTable *hashtable = [self.mapTable objectForKey:target];
        if (hashtable == nil) {
            hashtable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory capacity:5];
            [self.mapTable setObject:hashtable forKey:target];
        }
        if (![hashtable containsObject:thread]) {
            [hashtable addObject:thread];
        }
    }
}

- (void)cancelAndRemoveThreadsInTarget:(id)target {
    @synchronized(self) {
        NSHashTable *hashtable = [self.mapTable objectForKey:target];
        if (hashtable != nil) {
            NSArray *objects = [hashtable allObjects];
            for (id<OperationProtocol> thread in objects) {
                [thread cancel];
            }
        }
        [self.mapTable removeObjectForKey:target];
    }
}
@end
