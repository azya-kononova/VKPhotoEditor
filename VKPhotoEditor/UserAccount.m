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
@synthesize accessToken;
@synthesize lastPhotos;
@synthesize account;

+ (id)accountWithDict:(NSDictionary*)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    UserAccount *profile = [UserAccount new];
    profile.account = [Account accountWithDict:dict];
    return profile;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:account:'%@', token: '%@', photos total:%d>", NSStringFromClass(self.class), account, accessToken, lastPhotos.count];
}

@end
