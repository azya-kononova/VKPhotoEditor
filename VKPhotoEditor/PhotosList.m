//
//  PhotosList.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotosList.h"
#import "RequestExecutorDelegateAdapter.h"
#import "VKConnectionService.h"
#import "VKPhoto.h"
#import "VKRequestExecutor.h"
#import "NSObject+Map.h"

@interface PhotosList () <VKRequestExecutorDelegate>
@end

@implementation PhotosList {
    VKConnectionService *service;
    NSInteger nextPage;
    VKRequestExecutor *exec;
    NSInteger initialOffest;
}
@synthesize photos;
@synthesize limit;
@synthesize completed;
@synthesize delegate;

- (id)initWithPhotos:(NSArray*)_photos
{
    if (self = [super init]) {
        photos = [_photos copy];
        initialOffest = photos.count;
        service = [VKConnectionService shared];
        limit = 20;
    }
    return self;
}

- (void)reset
{
    exec = nil;
    nextPage = 0;
    completed = NO;
    photos = nil;
}

- (void)loadNextPageFor:(NSInteger)userId
{
    if (exec) return;
    exec = [service getPhotos:userId offset:initialOffest + limit*nextPage++];
    exec.delegate = self;
    [exec start];
}

- (void)append:(NSArray*)_photos
{
    if (!photos) {
        photos = _photos.copy;
    } else {
        photos = [photos arrayByAddingObjectsFromArray:_photos];
    }
    [delegate photosList:self didUpdatePhotos:photos];
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(id)executor didFinishWithObject:(id)value
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [value objectForKey:@"users"]) {
        Account *acc = [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    NSArray *_photos = [[value objectForKey:@"photos"] map:^id(NSDictionary *dict) {
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:dict];
        photo.account = [accounts objectForKey:[dict objectForKey:@"user_id"]];
        return photo; }];
    exec = nil;
    completed = !_photos.count;
    [self append:_photos];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    exec = nil;
    completed = YES;
    [delegate photosList:self didFailToUpdate:error];
}

@end
