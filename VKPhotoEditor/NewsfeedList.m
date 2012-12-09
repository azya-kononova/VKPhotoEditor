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
    return [service getNewsfeedSince:nil after:after limit:self.limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    
    after = [data objectForKey:@"after"];
    
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
}

- (BOOL)completed
{
    return after && ![after isKindOfClass:[NSString class]];
}

- (void)reset
{
    [super reset];
    after = nil;
}

@end
