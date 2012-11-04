//
//  PhotosList.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserPhotosList.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "NSObject+Map.h"
#import "NSArray+Helpers.h"
#import "UserProfile.h"
#import "NSDictionary+Helpers.h"

@interface UserPhotosList () <VKRequestExecutorDelegate>
@end

@implementation UserPhotosList {
    VKConnectionService *service;
    NSInteger nextPage;
    VKRequestExecutor *exec;
    NSInteger initialOffset;
}
@synthesize photos;
@synthesize limit;
@synthesize completed;
@synthesize delegate;

- (void)_init
{
    service = [VKConnectionService shared];
    limit = 20;
}

- (id)init
{
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (id)initWithPhotos:(NSArray*)_photos
{
    if (self = [super init]) {
        [self _init];
        photos = [_photos copy];
        initialOffset = photos.count;

    }
    return self;
}

- (void)reset
{
    exec = nil;
    nextPage = 0;
    completed = NO;
    photos = nil;
    initialOffset = 0;
}

- (void)loadNextPageFor:(NSInteger)userId
{
    if (exec) return;
    exec = [service getPhotos:userId offset:initialOffset + limit * nextPage++ limit:limit];
    exec.delegate = self;
    [exec start];
}

- (void)append:(NSArray*)_photos totalCount:(NSUInteger)totalCount
{
    if (!photos) {
        photos = _photos.copy;
    } else {
        photos = [photos arrayByAddingObjectsFromArray:_photos];
    }
    completed = photos.count == totalCount;
    [delegate photosList:self didUpdatePhotos:photos];
}

- (void)insert:(VKPhoto*)photo
{
    initialOffset++;
    photos = [[NSArray arrayWithObject:photo] arrayByAddingObjectsFromArray:photos];
    [delegate photosList:self didUpdatePhotos:photos];
}

- (void)deletePhoto:(NSString *)photoId
{
    NSUInteger index;
    VKPhoto *photoToDelete = [photos find:^BOOL(VKPhoto *photo) { return [photo.photoId isEqualToString:photoId]; } index:&index];
    if (!photoToDelete) return;
    NSMutableArray *newPhotos = photos.mutableCopy;
    [newPhotos removeObjectAtIndex:index];
    photos = newPhotos.copy;
    initialOffset--;
    [delegate photosList:self didUpdatePhotos:photos];
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(id)executor didFinishWithObject:(id)value
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [value objectForKey:@"users"]) {
        Account *acc = [user integerForKey:@"id"] == service.account.accountId ? service.account : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    NSArray *_photos = [[value objectForKey:@"photos"] map:^id(NSDictionary *dict) {
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:dict];
        photo.account = [accounts objectForKey:[dict objectForKey:@"user_id"]];
        return photo; }];
    exec = nil;
    [self append:_photos totalCount:[[value objectForKey:@"count"] integerValue]];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    exec = nil;
    nextPage--;
    
    [delegate photosList:self didFailToUpdate:error];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    
}

@end
