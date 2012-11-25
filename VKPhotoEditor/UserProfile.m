//
//  UserAccount.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserProfile.h"
#import "NSDictionary+Helpers.h"
#import "Settings.h"
#import "ImageCache.h"
#import "NSCoding.h"

@implementation UserProfile {
    Settings *settings;
}
@synthesize lastPhotos;
@synthesize accessToken;
@synthesize avatarId;

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    ENCODEOBJECT(accessToken);
    ENCODEOBJECT(avatarId);
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        DECODEOBJECT(accessToken);
        DECODEOBJECT(avatarId);
    }
    return self;
}

+ (id)accountWithDict:(NSDictionary*)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    UserProfile *profile = [[UserProfile alloc] initWithID:[[dict objectForKey:@"id"] intValue]];
    profile.login = [dict objectForKey:@"login"];
    profile.avatarId = [[dict objectForKey:@"photo"] objectForKey:@"id"];
    [profile setPhotosInfo:dict];
    
    return profile;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:account:'%@', token: '%@', photos total:%d>", NSStringFromClass(self.class), self.login, self.accessToken, lastPhotos.count];
}

@end
