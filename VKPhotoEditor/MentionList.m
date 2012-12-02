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

#define AFTER_FALSE @"0"

@implementation MentionList {
    NSString *since;
    NSString *after;
}

@synthesize account;

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:account.accountId since:since after:after limit:limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    
    //TODO: may be check it in other way?...
    if ([data objectForKey:@"since"] && ![[data objectForKey:@"after"] isEqualToString:AFTER_FALSE]) {
        since = [data objectForKey:@"since"];
        after = [data objectForKey:@"after"];
    }
    
    for (NSDictionary *user in [data objectForKey:@"users"]) {
        Account *acc = [user integerForKey:@"id"] == service.profile.accountId ? service.profile : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    NSArray *_photos = [[data objectForKey:@"feedback"] map:^id(NSDictionary *dict) {
        NSDictionary *photoInfo = [dict objectForKey:@"photo"];
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:photoInfo];
        photo.account = [accounts objectForKey:[photoInfo objectForKey:@"user"]];
        photo.type = [VKPhoto photoType:[dict objectForKey:@"type"]];
        
        NSDictionary *replyDict = [photoInfo objectForKey:@"reply_to_photo"];
        photo.replyToPhoto = [VKPhoto VKPhotoWithDict:replyDict];
        photo.replyToPhoto.account = [accounts objectForKey:[replyDict objectForKey:@"user"]];
        
        return photo; }];
    [self append:_photos totalCount:0];
}

- (void)reset
{
    [super reset];
    since = nil;
    after = nil;
}

@end
