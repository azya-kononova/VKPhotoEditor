//
//  Settings.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Settings.h"
#import "NSObject+Map.h"
#import "AppDelegate.h"

#define LOGIN_KEY @"login"
#define SERVICE_URL_KEY @"serviceRootURL"

@interface NSUserDefaults (Def)
- (id)objectForKey:(NSString*)name withDef:(NSDictionary*)def map:(MapBlock)map;
@end

@implementation Settings {
    NSDictionary *defaults;
    NSUserDefaults *user;
}

- (id)initWithDefaults:(NSDictionary*)defs
{
    if (self = [super init]) {
        user = [NSUserDefaults standardUserDefaults];
        if (defs) {
            [user registerDefaults:defs];
            [self sync];
        }
    }
    return self;
}

+ (Settings*)current
{
    return [AppDelegate shared].settings;
}

- (NSURL*)serviceRootURL
{
    return [NSURL URLWithString:[user objectForKey:SERVICE_URL_KEY]];
}

- (NSString*)login
{
    return [user objectForKey:LOGIN_KEY];
}

- (void)setLogin:(NSString *)login
{
    [user setObject:login forKey:LOGIN_KEY];
    [self sync];
}

- (void)sync
{
    [user synchronize];
}

@end
