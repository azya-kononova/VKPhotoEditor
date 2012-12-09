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
#import "Settings.h"

@implementation MentionList {
    NSString *after;
}

@synthesize account, mentionsCount;

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:account.accountId since:nil after:after limit:self.limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    
    service.replySince = [data objectForKey:@"since"];
    after = [data objectForKey:@"after"];
    
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
    
    mentionsCount = _photos.count;
    
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

- (void)saveSinceValue
{
    [Settings current].replySince = service.replySince;
}

//It's a stub for stupid server data!!!
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
