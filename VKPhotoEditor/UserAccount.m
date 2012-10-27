//
//  UserAccount.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserAccount.h"
#import "NSDictionary+Helpers.h"

@implementation UserAccount
@synthesize accountId;
@synthesize accessToken;
@synthesize login;
@synthesize lastPhotos;

- (id)initWithID:(NSInteger)_id
{
    if (self = [super init]) {
        accountId = _id;
    }
    return self;
}

+ (id)accountWithDict:(NSDictionary*)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    UserAccount *account = [[UserAccount alloc] initWithID:[dict integerForKey:@"user_id"]];
    account.accessToken = [dict objectForKey:@"access_token"];
    return account;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%d access_token:'%@' login:'%@' photos total:%d>", NSStringFromClass(self.class), accountId, accessToken, login, lastPhotos.count];
}

@end
