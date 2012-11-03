//
//  RequestExecutorProxy.m
//  VK
//
//  Created by Sergey Martynov on 06.02.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "RequestExecutorProxy.h"
#import "NSObject+Invocation.h"

@implementation RequestExecutorProxy {
    VKRequestExecutor *realExec;
}
@synthesize target;
@synthesize onSuccess;
@synthesize onError;

- (id)initWithRequest:(NSURLRequest *)request
{
    if (self = [super init]) {
        realExec = [[VKRequestExecutor alloc] initWithRequest:request];
        realExec.delegate = self;
    }
    return self;
}

- (void)start { [realExec start]; }
- (void)stop  { [realExec stop]; }

- (BOOL)isFinished
{
    return realExec.isFinished;
}

- (void)VKRequestExecutor:(VKRequestExecutor*)executor didFinishWithObject:(id)value
{
    if (onSuccess) {
        [target invokeSelector:onSuccess withObject:executor withObject:value];
    }
    [self.delegate VKRequestExecutor:self didFinishWithObject:value];
}

- (void)VKRequestExecutor:(VKRequestExecutor*)executor didFailedWithError:(NSError*)error
{
    if (onError) {
        [target invokeSelector:onError withObject:executor withObject:error];
    }
    [self.delegate VKRequestExecutor:self didFailedWithError:error];
    
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    [self.delegate VKRequestExecutor:self didAlreadyUpload:progress];
}

- (void)dealloc
{
    realExec.delegate = nil;
}

@end
