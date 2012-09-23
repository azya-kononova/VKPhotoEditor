//
//  NSArray+Creation.m
//  FeedReader
//
//  Created by Ekaterina Petrova on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Creation.h"

@implementation NSArray (Creation)

+ (NSArray*)arrayWithObject:(id)obj count:(NSUInteger)count
{
    return [[self mutableArrayWithObject:obj count:count] copy];
}

+ (NSMutableArray*)mutableArrayWithObject:(id)obj count:(NSUInteger)count
{
    NSMutableArray *arr = [NSMutableArray new];
    for (NSUInteger i = 0; i < count; ++i) {
        [arr addObject:obj];
    }
    return arr;
}

@end
