//
//  NSObject+Map.h
//  Radario
//
//  Created by Sergey Martynov on 26.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^MapBlock)(id);
typedef id (^MapKVBlock)(id, id);

@protocol Map
- (id)map:(MapBlock)map;
@end

@protocol MapKV
- (id)mapKV:(MapKVBlock)map;
@end


@interface NSObject (Map)
- (id)map:(MapBlock)map;
@end

@interface NSArray (Map) <Map>
@end

@interface NSMutableArray (Map) <Map>
@end

@interface NSSet (Map) <Map>
@end

@interface NSMutableSet (Map) <Map>
@end

@interface NSDictionary (Map) <MapKV>
@end

@interface NSMutableDictionary (Map) <MapKV>
@end
