//
//  ReplyPhotoList.m
//  VKPhotoEditor
//
//  Created by asya on 12/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ReplyPhotoList.h"
#import "NSDictionary+Helpers.h"
#import "NSObject+Map.h"
#import "VKPhoto.h"

@implementation ReplyPhotoList {
    NSString *photoID;
}

- (id)initWithPhotoID:(NSString *)_photoID
{
    self = [super init];
    if (self) {
        photoID = _photoID;
    }
    return self;
}

- (VKRequestExecutor*)newPageExec
{
    return [service getHistory:photoID limit:self.limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [data objectForKey:@"users"]) {
        Account *acc = [user integerForKey:@"id"] == service.profile.accountId ? service.profile : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    NSArray *_photos = [[data objectForKey:@"photos"] map:^id(NSDictionary *dict) {
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:dict];
        photo.account = [accounts objectForKey:[dict objectForKey:@"user"]];
        
        NSDictionary *replyDict = [dict objectForKey:@"reply_to_photo"];
        photo.replyToPhoto = [VKPhoto VKPhotoWithDict:replyDict];
        photo.replyToPhoto.account = [accounts objectForKey:[replyDict objectForKey:@"user"]];
        return photo; }];
    [self append:_photos totalCount:[[data objectForKey:@"count"] integerValue]];
}

@end
