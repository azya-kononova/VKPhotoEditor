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
    NSString *after;
}

@synthesize account;

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:account.accountId since:nil after:after limit:limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    
    after = [[data objectForKey:@"after"] stringValue];
    
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
    //It's a stub for stupid server data!!!
    [self append:_photos totalCount:0];
    
    completed = [after isEqualToString:@"0"];
}

- (void)reset
{
    [super reset];
    after = nil;
}

- (NSArray *)getPhotosChain:(NSArray *)photos
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:photos];
    
    for (VKPhoto *photo in photos) {
        [self addPhotoReplyTo:photo from:result];
    }
    return result;
}

- (void)addPhotoReplyTo:(VKPhoto *)reply from:(NSMutableArray *)array
{
    VKPhoto *removedPhoto = nil;
    
    for (VKPhoto *photo in array) {
        if ([photo.photoId isEqualToString:reply.replyTo]) {
            removedPhoto = photo;
            break;
        }
    }
    
    if (removedPhoto) {
        reply.replyToPhoto = removedPhoto;
        [array removeObject:removedPhoto];
    }
}

@end
