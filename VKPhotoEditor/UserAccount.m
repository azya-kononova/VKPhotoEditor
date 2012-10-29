//
//  UserAccount.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserAccount.h"
#import "NSDictionary+Helpers.h"
#import "Settings.h"
#import "ImageCache.h"

@implementation UserAccount {
    Settings *settings;
}
@synthesize lastPhotos;

- (id)init
{
    if (self = [super init]) {
        settings = [Settings current];
    }
    return self;
}

+ (id)accountWithDict:(NSDictionary*)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    UserAccount *profile = [UserAccount new];
    profile.accountId = [[dict objectForKey:@"id"] intValue];
    profile.login = [dict objectForKey:@"login"];
    profile.avatarUrl = [NSURL URLWithString:[[dict objectForKey:@"photo"] objectForKey:@"photo_small"]];
    
    return profile;
}

- (void)setAccountId:(NSInteger)accountId
{
    settings.userId = [NSNumber numberWithInt:accountId];
}

- (NSInteger)accountId
{
    return [[settings userId] intValue];
}

- (void)setLogin:(NSString *)login
{
    settings.login = login;
}

- (NSString*)login
{
    return settings.login;
}

- (void)setAccessToken:(NSString *)accessToken
{
    settings.accessToken = accessToken;
}

- (NSString*)accessToken
{
    return settings.accessToken;
}

- (NSURL*)avatarUrl
{
    return settings.avatarURL;
}

- (void)setAvatarUrl:(NSURL *)avatarUrl
{
    settings.avatarURL = avatarUrl;
}

- (RemoteImage*)avatar
{
    return [[ImageCache shared] remoteImageForURL:self.avatarURL];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:account:'%@', token: '%@', photos total:%d>", NSStringFromClass(self.class), self.login, self.accessToken, lastPhotos.count];
}

- (void)logout
{
    self.accountId = 0;
    self.avatarURL = nil;
    self.login = nil;
    self.accessToken = nil;
}

@end
