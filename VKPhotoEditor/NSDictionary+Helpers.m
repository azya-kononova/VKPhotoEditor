//
//  NSDictionary+Helpers.m
//  Radario
//
//  Created by Sergey Martynov on 26.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "NSDictionary+Helpers.h"

@implementation NSDictionary (Helpers)

- (id)objectWithIndex:(NSUInteger)index
{
    return [self objectForKey:[NSNumber numberWithUnsignedInteger:index]];
}

- (NSInteger)integerForKey:(id)key 
{
    return [[self nonNullObjectForKey:key] integerValue];
}

- (BOOL)boolForKey:(id)key
{
    return [[self nonNullObjectForKey:key] boolValue];
}

- (double)doubleForKey:(id)key
{
    return [[self nonNullObjectForKey:key] doubleValue];
}

- (id)nonNullObjectForKey:(id)key
{
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSNull class]]) {
        value = nil;
    }
    return value;
}

- (NSURL*)urlForKey:(id)key
{
    NSString *str = [self objectForKey:key];
    if (![str isKindOfClass:[NSString class]]) return nil;
    return [NSURL URLWithString:str];
}


- (NSDate*)dateForKey:(id)key formatter:(NSDateFormatter*)formatter
{
    id date = [self nonNullObjectForKey:key];
    if (date && ![date isKindOfClass:[NSDate class]]) {
        date = [formatter dateFromString:[date description]];
    }
    return date;
}

@end

@implementation NSMutableDictionary (Helpers)

- (void)setObject:(id)obj forIndex:(NSUInteger)index
{
    [self setObject:obj forKey:[NSNumber numberWithUnsignedInteger:index]];
}

@end
