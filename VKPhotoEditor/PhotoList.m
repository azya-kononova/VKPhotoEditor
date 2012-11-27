//
//  PhotoList.m
//  VKPhotoEditor
//
//  Created by Kate on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoList.h"

@implementation PhotoList
@synthesize delegate;
@synthesize completed;
@synthesize photos;

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
    initialOffset = 0;
}

- (void)loadMore;
{
    exec.delegate = self;
    [exec start];
}

// Implement in child classes

- (void)mapData:(id)data
{
}

- (void)append:(NSArray*)_photos totalCount:(NSUInteger)totalCount
{
    if (!photos) {
        photos = _photos.copy;
    } else {
        photos = [photos arrayByAddingObjectsFromArray:_photos];
    }
    completed = photos.count == totalCount;
    [delegate photoList:self didUpdatePhotos:photos];
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(id)executor didFinishWithObject:(id)value
{
    [self mapData:value];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    exec = nil;
    nextPage--;
    [delegate photoList:self didFailToUpdate:error];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
}

@end


