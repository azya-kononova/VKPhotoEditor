//
//  NSArray+Creation.h
//  FeedReader
//
//  Created by Ekaterina Petrova on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Creation)

+ (NSArray*)arrayWithObject:(id)obj count:(NSUInteger)count;
+ (NSMutableArray*)mutableArrayWithObject:(id)obj count:(NSUInteger)count;

@end
