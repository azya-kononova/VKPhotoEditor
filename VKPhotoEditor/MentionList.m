//
//  MentionList.m
//  VKPhotoEditor
//
//  Created by Kate on 11/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "MentionList.h"
#import "NSDictionary+Helpers.h"
#import "NSObject+Map.h"
#import "VKPhoto.h"

@implementation MentionList
@synthesize account;

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:account.accountId since:nil after:nil limit:limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [data objectForKey:@"users"]) {
        Account *acc = [user integerForKey:@"id"] == service.profile.accountId ? service.profile : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    NSArray *_photos = [[data objectForKey:@"feedback"] map:^id(NSDictionary *dict) {
        NSDictionary *photoInfo = [dict objectForKey:@"photo"];
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:photoInfo];
        photo.account = [accounts objectForKey:[photoInfo objectForKey:@"user_id"]];
        return photo; }];
    [self append:_photos totalCount:0];
}

@end
