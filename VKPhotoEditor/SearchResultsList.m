//
//  AllPhotosList.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "SearchResultsList.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "NSArray+Helpers.h"
#import "NSObject+Map.h"
#import "VKPhoto.h"

@interface SearchResultsList () <VKRequestExecutorDelegate>
@end

@implementation SearchResultsList
@synthesize query;

- (VKRequestExecutor*)newPageExec
{
   return [service searchPhotos:query offset:self.photos.count limit:self.limit];
}

- (void)mapData:(id)data
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *account in [data objectForKey:@"users"]) {
        Account *acc = [Account accountWithDict:account];
        [accounts setObject:acc forKey:[account objectForKey:@"id"]];
    }
    
    NSArray *results = [data objectForKey:@"results"];
    
    NSMutableArray *_photos = [results map:^id(NSDictionary *dict) {
        NSDictionary *photoInfo = [dict objectForKey:@"photo"];
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:photoInfo];
        photo.account = [accounts objectForKey:[photoInfo objectForKey:@"user"]];
        
        NSDictionary *replyDict = [dict objectForKey:@"reply_to_photo"];
        photo.replyToPhoto = [VKPhoto VKPhotoWithDict:replyDict];
        photo.replyToPhoto.account = [accounts objectForKey:[replyDict objectForKey:@"user"]];
        
        return photo;
    }];
    
    NSDictionary *_user = [results find:^BOOL(NSDictionary *result) { return [[result objectForKey:@"type"] isEqualToString:@"user"]; } ];
    if (_user && ![_user objectForKey:@"photo"]) {
        VKPhoto *photo = [VKPhoto new];
        photo.account = [accounts objectForKey:[_user objectForKey:@"user"]];
        [_photos insertObject:photo atIndex:0];
    }
    
    [self append:_photos totalCount:[[data objectForKey:@"count"] integerValue]];
}

@end

