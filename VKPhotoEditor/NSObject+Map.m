//
//  NSObject+Map.m
//  Radario
//
//  Created by Sergey Martynov on 26.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "NSObject+Map.h"

static id _map(id self, id res, MapBlock map)
{
    for (id obj in self) {
        id mobj = map(obj);
        if (mobj) {
            [res addObject:mobj];
        }
    }
    return res;
}

static id _kvmap(id self, id res, MapKVBlock map)
{
    for (id key in self) {
        id mobj = map(key, [self objectForKey:key]);
        if (mobj) {
            [res setObject:mobj forKey:key];
        }
    }
    return res;
}

@implementation NSObject (Map)
- (id)map:(MapBlock)map
{
    return map(self);
}
@end


@implementation NSArray (Map)
- (id)map:(MapBlock)map
{
    return [_map(self, [NSMutableArray arrayWithCapacity:self.count], map) copy];
}
@end


@implementation NSMutableArray (Map)
- (id)map:(MapBlock)map
{
    return _map(self, [NSMutableArray arrayWithCapacity:self.count], map);
}
@end


@implementation NSSet (Map)
- (id)map:(MapBlock)map
{
    return [_map(self, [[NSMutableSet alloc] initWithCapacity:self.count], map) copy];
}
@end

@implementation NSMutableSet (Map)
- (id)map:(MapBlock)map
{
    return _map(self, [[NSMutableSet alloc] initWithCapacity:self.count], map);
}
@end


@implementation NSDictionary (Map)
- (id)mapKV:(MapKVBlock)map
{
    return [_kvmap(self, [[NSMutableDictionary alloc] initWithCapacity:self.count], map) copy];
}
@end


@implementation NSMutableDictionary (Map)
- (id)mapKV:(MapKVBlock)map
{
    return _kvmap(self, [[NSMutableDictionary alloc] initWithCapacity:self.count], map);
}
@end
