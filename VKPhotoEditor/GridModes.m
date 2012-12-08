//
//  GridModes.m
//  VKPhotoEditor
//
//  Created by asya on 12/8/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "GridModes.h"

@implementation GridModes {
    NSMutableDictionary *modes;
    NSString *currentKey;
}

- (id)init
{
    self = [super init];
    if (self) {
        modes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setMode:(BOOL)mode forKey:(NSString *)key
{
    [modes setObject:[NSNumber numberWithBool:mode] forKey:key];
}

- (void)switchCurrentModeValue
{
    [self setMode:!self.isGridMode forKey:currentKey];
}

- (void)setCurrentModeKey:(NSString *)key
{
    currentKey = key;
}

- (BOOL)isGridMode
{
    return [[modes objectForKey:currentKey] boolValue];
}

@end
