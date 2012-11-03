//
//  RequestExecutorDelegateApadter.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RequestExecutorDelegateAdapter.h"
#import "NSObject+Invocation.h"

@interface RequestHandler : NSObject
@property (nonatomic, assign) SEL onSuccess;
@property (nonatomic, assign) SEL onError;
@end

@implementation RequestHandler
@synthesize onSuccess;
@synthesize onError;
@end

typedef void (^Visitor)(RequestHandler *handler);

@implementation RequestExecutorDelegateAdapter {
    NSMutableArray *executors;
    NSMutableArray *handlers;
}
@synthesize delegate;
@synthesize target;

- (id)initWithTarget:(id)_target
{
    if (self = [super init]) {
        target = _target;
        executors = [NSMutableArray new];
        handlers = [NSMutableArray new];
    }
    return self;
}

- (BOOL)completed
{
    for (VKRequestExecutor *executor in executors) {
        if (!executor.isFinished) return NO;
    }
    return YES;
}

- (void)start:(VKRequestExecutor*)exec onSuccess:(SEL)success onError:(SEL)error
{
    if (!exec) return;
    RequestHandler *handler = [RequestHandler new];
    handler.onSuccess = success;
    handler.onError = error;
    exec.delegate = self;
    [executors addObject:exec];
    [handlers addObject:handler];
    [exec start];
    [delegate adapter:self didStartRequest:exec];
}

- (void)stopAll
{
    [executors removeAllObjects];
    [handlers removeAllObjects];
}

- (void)executorFinished:(VKRequestExecutor*)exec visitor:(Visitor)visitor remove:(BOOL)remove;
{
    NSUInteger idx = [executors indexOfObject:exec];
    if (idx == NSNotFound) return;
    RequestHandler *handler = [handlers objectAtIndex:idx];
    if (remove) {
        [executors removeObjectAtIndex:idx];
        [handlers removeObjectAtIndex:idx];
    }
    visitor(handler);
    if ([self completed]) {
        [delegate adapterDidCompleteAll:self];
    }
}

- (void)VKRequestExecutor:(VKRequestExecutor*)exec didFinishWithObject:(id)value
{
    [self executorFinished:exec visitor:^(RequestHandler *handler) {
        if (handler.onSuccess) {
            [target invokeSelector:handler.onSuccess withObject:exec withObject:value];
        }
    } remove:YES];
}

- (void)VKRequestExecutor:(VKRequestExecutor*)exec didFailedWithError:(NSError*)error
{
    [self executorFinished:exec visitor:^(RequestHandler *handler) {
        if (handler.onError) {
            [target invokeSelector:handler.onError withObject:exec withObject:error];
        }
    } remove:NO];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    
}
@end