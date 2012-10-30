//
//  NSArray+Helpers.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "NSArray+Helpers.h"

@implementation NSArray (Helpers)

- (id)find:(Pred)pred {
    return [self find:pred index:nil];
}

- (id)find:(Pred)pred index:(NSUInteger*)index
{
    __block id result;
    NSUInteger idx = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if (!pred(obj)) return NO;
        result = obj;
        *stop = YES;
        return YES;
    }];
    if (result && index) *index = idx;
    return result;
}

@end
