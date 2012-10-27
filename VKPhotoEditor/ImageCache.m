//
//  ImageCache.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ImageCache.h"
#import "AppDelegate.h"

@implementation ImageCache {
    NSMutableDictionary *images;
}

+ (ImageCache*)shared
{
    return [AppDelegate shared].imageCache;
}

- (id)init
{
    if (self = [super init]) {
        images = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (RemoteImage*)remoteImageForURL:(NSURL*)url
{
    if (!url) return nil;
    if (![url isKindOfClass:[NSURL class]]) {
        return nil;
    }
    RemoteImage *image = [images objectForKey:url];
    if (!image) {
        image = [[RemoteImage alloc] initWithURL:url];
        [images setObject:image forKey:url];
    }
    return image;
}

- (BOOL)hasRemoteImageForURL:(NSURL *)url {
    return [images objectForKey:url] != nil;
}

- (void)handleMemoryWarning:(NSNotification *)notification
{
    [images removeAllObjects];
}

@end