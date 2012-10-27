//
//  NSObject+Invocation.h
//  Radario
//
//  Created by Sergey Martynov on 06.02.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Invocation)

- (NSInvocation*)invocationForSelector:(SEL)sel;

- (void)invokeSelector:(SEL)sel withObject:(id)object1 withObject:(id)object2;

@end

