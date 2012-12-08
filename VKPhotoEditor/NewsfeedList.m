//
//  NewsfeedList.m
//  VKPhotoEditor
//
//  Created by asya on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "NewsfeedList.h"
#import "VKPhoto.h"
#import "NSDictionary+Helpers.h"
#import "NSObject+Map.h"
#import "Settings.h"

@implementation NewsfeedList {
    NSString *after;
}

@synthesize newsfeedCount;

- (VKRequestExecutor*)newPageExec
{
    return [service getNewsfeedSince:nil after:after limit:limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    
    for (NSDictionary *user in [data objectForKey:@"users"]) {
        Account *acc = [user integerForKey:@"id"] == service.profile.accountId ? service.profile : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    NSArray *_photos = [[data objectForKey:@"news"] map:^id(NSDictionary *dict) {
        NSDictionary *photoInfo = [dict objectForKey:@"photo"];
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:photoInfo];
        photo.account = [accounts objectForKey:[photoInfo objectForKey:@"user"]];
        photo.type = [VKPhoto photoType:[dict objectForKey:@"type"]];
        
        NSDictionary *replyDict = [photoInfo objectForKey:@"reply_to_photo"];
        photo.replyToPhoto = [VKPhoto VKPhotoWithDict:replyDict];
        photo.replyToPhoto.account = [accounts objectForKey:[replyDict objectForKey:@"user"]];
        
        return photo; }];
    
    newsfeedCount = _photos.count;
    
    [self append:_photos totalCount:0];
    
    service.newsfeedSince = [data objectForKey:@"since"];
    after = [data objectForKey:@"after"];
    
    completed = ![after isKindOfClass:[NSString class]];
    
}

- (void)saveSinceValue
{
    [Settings current].newsfeedSince = service.newsfeedSince;
}

- (void)reset
{
    [super reset];
    after = nil;
}

@end
