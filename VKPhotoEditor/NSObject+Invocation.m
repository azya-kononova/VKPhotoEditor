//
//  NSObject+Invocation.m
//  Radario
//
//  Created by Sergey Martynov on 06.02.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "NSObject+Invocation.h"

@implementation NSObject (Invocation)

- (NSInvocation*)invocationForSelector:(SEL)sel
{
    if (!sel) return nil;
    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
    if (!sig) return nil;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = sel;
    return inv;
}

- (void)invokeSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"        
    [self performSelector:sel withObject:obj1 withObject:obj2];
#pragma clang diagnostic pop
}

@end

