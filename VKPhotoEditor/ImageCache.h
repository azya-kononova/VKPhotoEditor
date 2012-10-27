//
//  ImageCache.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RemoteImage.h"

@interface ImageCache : NSObject

+ (ImageCache*)shared;

- (RemoteImage*)remoteImageForURL:(NSURL*)url;

- (BOOL)hasRemoteImageForURL:(NSURL *)url;

@end
