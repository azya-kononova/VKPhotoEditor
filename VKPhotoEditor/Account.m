//
//  Account.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Account.h"
#import "NSDictionary+Helpers.h"
#import "ImageCache.h"
#import "NSCoding.h"

@implementation Account
@synthesize accountId;
@synthesize login;
@synthesize thumbnailAvatarUrl;
@synthesize avatarUrl;

- (id)initWithID:(NSInteger)_id
{
    if (self = [super init]) {
        accountId = _id;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        DECODEINT(accountId);
        DECODEOBJECT(login);
        DECODEOBJECT(thumbnailAvatarUrl);
        DECODEOBJECT(avatarUrl);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    ENCODEINT(accountId);
    ENCODEOBJECT(login);
    ENCODEOBJECT(thumbnailAvatarUrl);
    ENCODEOBJECT(avatarUrl);
}

+ (id)accountWithDict:(NSDictionary*)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    Account *account = [[Account alloc] initWithID:[dict integerForKey:@"id"]];
    account.login = [dict objectForKey:@"login"];
    [account setPhotosInfo:dict];
    return account;
}

- (void)setPhotosInfo:(NSDictionary*)dict
{
    self.avatarUrl = [NSURL URLWithString:[[dict objectForKey:@"photo"] objectForKey:@"photo_big"]];
    self.thumbnailAvatarUrl = [NSURL URLWithString:[[dict objectForKey:@"photo"] objectForKey:@"photo_small"]];
}

- (RemoteImage*)avatar
{
    return [[ImageCache shared] remoteImageForURL:avatarUrl];
}

- (RemoteImage*)thumbnailAvatar
{
    return [[ImageCache shared] remoteImageForURL:thumbnailAvatarUrl];
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%d login:'%@' ", NSStringFromClass(self.class), accountId, login];
}

@end
