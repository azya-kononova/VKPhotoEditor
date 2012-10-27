//
//  NSDictionary+Helpers.h
//  Radario
//
//  Created by Sergey Martynov on 26.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Helpers)

- (id)objectWithIndex:(NSUInteger)index;

- (NSInteger)integerForKey:(id)key;

- (BOOL)boolForKey:(id)key;

- (double)doubleForKey:(id)key;

- (id)nonNullObjectForKey:(id)key;

- (NSDate*)dateForKey:(id)key formatter:(NSDateFormatter*)formatter;

- (NSURL*)urlForKey:(id)key;

@end

@interface NSMutableDictionary (Helpers)

- (void)setObject:(id)obj forIndex:(NSUInteger)index;

@end
