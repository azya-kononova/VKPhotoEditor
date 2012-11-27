//
//  PhotosList.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserPhotoList.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "NSObject+Map.h"
#import "NSArray+Helpers.h"
#import "UserProfile.h"
#import "NSDictionary+Helpers.h"

@interface UserPhotoList () <VKRequestExecutorDelegate>
@end

@implementation UserPhotoList 
@synthesize userPic;

- (id)initWithPhotos:(NSArray*)_photos
{
    if (self = [super init]) {
        self.photos = [_photos copy];
        initialOffset = self.photos.count;

    }
    return self;
}

- (void)loadPageFor:(Account *)account
{
    if (exec) return;
    exec = [service getPhotos:account.accountId offset:initialOffset + limit * nextPage++ limit:limit userPic:userPic];
    [self loadMore];
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
        photo.account = [accounts objectForKey:[dict objectForKey:@"user_id"]];
        return photo; }];
    exec = nil;
    [self append:_photos totalCount:[[data objectForKey:@"count"] integerValue]];
}

- (void)insert:(VKPhoto*)photo
{
    initialOffset++;
    self.photos = [[NSArray arrayWithObject:photo] arrayByAddingObjectsFromArray:self.photos];
    [self.delegate photoList:self didUpdatePhotos:self.photos];
}

- (void)deletePhoto:(NSString *)photoId
{
    NSUInteger index;
    VKPhoto *photoToDelete = [self.photos find:^BOOL(VKPhoto *photo) { return [photo.photoId isEqualToString:photoId]; } index:&index];
    if (!photoToDelete) return;
    NSMutableArray *newPhotos = self.photos.mutableCopy;
    [newPhotos removeObjectAtIndex:index];
    self.photos = newPhotos.copy;
    initialOffset--;
    [self.delegate photoList:self didUpdatePhotos:self.photos];
}

@end
