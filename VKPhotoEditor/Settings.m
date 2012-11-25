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

#define SERVICE_URL_KEY @"serviceRootURL"
#define ERRORS_DESCRIPTIONS_KEY @"errorsDescriptions"
#define FIRST_LAUNCH_KEY @"firstLaunch"
#define PROFILE_KEY @"profile"

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
            [user synchronize];
        }
    }
    return self;
}

+ (Settings*)current
{
    return [AppDelegate shared].settings;
}

- (NSString*)descriptionForErrorKey:(NSString *)errorKey
{
    return [[user objectForKey:ERRORS_DESCRIPTIONS_KEY] objectForKey:errorKey];
}

- (NSURL*)serviceRootURL
{
    return [NSURL URLWithString:[user objectForKey:SERVICE_URL_KEY]];
}

- (BOOL)firstLaunch
{
    return [user boolForKey:FIRST_LAUNCH_KEY];
}

- (void)setFirstLaunch:(BOOL)firstLaunch
{
    [user setBool:firstLaunch forKey:FIRST_LAUNCH_KEY];
    [user synchronize];
}

- (UserProfile*)profile
{
    NSData *profileData = [user objectForKey:PROFILE_KEY];
    return  profileData ? [NSKeyedUnarchiver unarchiveObjectWithData:profileData] : nil;
}

- (void)setProfile:(UserProfile *)profile
{
    [user setObject:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:PROFILE_KEY];
    [user synchronize];
}

- (void)sync
{
    [user synchronize];
}

@end