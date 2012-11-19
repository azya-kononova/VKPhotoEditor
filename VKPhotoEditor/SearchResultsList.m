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

@implementation SearchResultsList {
    VKConnectionService *service;
    NSInteger nextPage;
    VKRequestExecutor *exec;
}
@synthesize photos;
@synthesize limit;
@synthesize completed;
@synthesize delegate;
@synthesize user;

- (id)init
{
    if (self = [super init]) {
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

- (void)loadNextPageFor:(NSString*)query
{
    if (exec) return;
    exec = [service searchPhotos:query offset:limit*nextPage++ limit:limit];
    exec.delegate = self;
    [exec start];
}

- (void)append:(NSArray*)_photos total:(NSUInteger)total;
{    
    if (!photos) {
        photos = _photos.copy;
    } else {
        photos = [photos arrayByAddingObjectsFromArray:_photos];
    }
    
    completed = _photos.count == total;
    
    [delegate searchResultsList:self didUpdatePhotos:photos user:nil];
}

- (void)deletePhoto:(NSString *)photoId
{
    NSUInteger index;
    VKPhoto *photoToDelete = [photos find:^BOOL(VKPhoto *photo) { return [photo.photoId isEqualToString:photoId]; } index:&index];
    if (!photoToDelete) return;
    NSMutableArray *newPhotos = photos.mutableCopy;
    [newPhotos removeObjectAtIndex:index];
    photos = newPhotos.copy;
    [delegate searchResultsList:self didUpdatePhotos:photos user:user];
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(id)executor didFinishWithObject:(id)value
{
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *account in [value objectForKey:@"users"]) {
        Account *acc = [Account accountWithDict:account];
        [accounts setObject:acc forKey:[account objectForKey:@"id"]];
    }
    
    NSArray *results = [value objectForKey:@"results"];
    
    NSMutableArray *_photos = [results map:^id(NSDictionary *dict) {
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:[dict objectForKey:@"photo"]];
        photo.account = [accounts objectForKey:[dict objectForKey:@"user_id"]];
        return photo;
    }];
    
    NSDictionary *_user = [results find:^BOOL(NSDictionary *result) { return [[result objectForKey:@"type"] isEqualToString:@"user"]; } ];
    if (_user && ![_user objectForKey:@"photo"]) {
        VKPhoto *photo = [VKPhoto new];
        photo.account = [accounts objectForKey:[_user objectForKey:@"user_id"]];
        [_photos insertObject:photo atIndex:0];
    }
    
    exec = nil;
    
    [self append:_photos total:[[value objectForKey:@"count"] integerValue]];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    exec = nil;
    nextPage--;
    [delegate searchResultsList:self didFailToUpdate:error];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
}
@end


