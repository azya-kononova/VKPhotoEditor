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
        DECODEOBJECT(avatarUrl);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    ENCODEINT(accountId);
    ENCODEOBJECT(login);
    ENCODEOBJECT(avatarUrl);
}

+ (id)accountWithDict:(NSDictionary*)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    Account *account = [[Account alloc] initWithID:[dict integerForKey:@"id"]];
    account.login = [dict objectForKey:@"login"];
    account.avatarUrl = [NSURL URLWithString:[[dict objectForKey:@"photo"] objectForKey:@"photo_small"]];
    return account;
}

- (RemoteImage*)avatar
{
    return [[ImageCache shared] remoteImageForURL:avatarUrl];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%d login:'%@' ", NSStringFromClass(self.class), accountId, login];
}

@end
