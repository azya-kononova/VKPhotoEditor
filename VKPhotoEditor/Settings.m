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
#define USER_ID_KEY @"userId"
#define ACCESS_TOKEN_KEY @"accessToken"
#define AVATAR_URL_KEY @"avatarURL"
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

- (NSNumber*)user_id
{
    return [user objectForKey:USER_ID_KEY];
}

- (void)setUserId:(NSNumber *)userId
{
    [user setObject:userId forKey:USER_ID_KEY];
    [self sync];
}

- (NSString*)accessToken
{
     return [user objectForKey:ACCESS_TOKEN_KEY];
}

- (void)setAccessToken:(NSString *)accessToken
{
    [user setObject:accessToken forKey:ACCESS_TOKEN_KEY];
    [self sync];
}

- (NSURL*)avatarURL
{
     return [user objectForKey:AVATAR_URL_KEY];
}

- (void)setAvatarURL:(NSURL *)avatarURL
{
    [user setObject:avatarURL forKey:AVATAR_URL_KEY];
    [self sync];
}

- (void)sync
{
    [user synchronize];
}

@end
