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

- (void)append:(NSArray*)_photos user:(NSDictionary*)_user total:(NSUInteger)total;
{
    if (_user) total = total - 1;

    
    if (!photos) {
        photos = _photos.copy;
    } else {
        photos = [photos arrayByAddingObjectsFromArray:_photos];
    }
    
    completed = _photos.count == total;
    
    [delegate searchResultsList:self didUpdatePhotos:photos user:nil];
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
    
    //TODO: user???
    
    NSDictionary *_user = [results find:^BOOL(NSDictionary *result) { return [[result objectForKey:@"type"] isEqualToString:@"user"]; } ];
    
    NSArray *_photos = [results map:^id(NSDictionary *dict) {
        if ([[dict objectForKey:@"type"] isEqualToString:@"user"]) return nil;
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:[dict objectForKey:@"photo"]];
        photo.account = [accounts objectForKey:[dict objectForKey:@"user_id"]];
        return photo;
    }];
    
    exec = nil;
    
    [self append:_photos user:_user total:[[value objectForKey:@"count"] integerValue]];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    exec = nil;
    nextPage--;
    [delegate searchResultsList:self didFailToUpdate:error];
}

@end


