//
//  VKPhoto.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKPhoto.h"
#import "NSDictionary+Helpers.h"
#import "ImageCache.h"

@implementation VKPhoto
@synthesize photoId;
@synthesize imageURL;
@synthesize caption;
@synthesize date;
@synthesize account;
@synthesize justUploaded;
@synthesize thumbnailURL;

- (id)initWithID:(NSString*)_id
{
    if (self = [super init]) {
        photoId = _id;
    }
    return self;
}


+ (id)VKPhotoWithDict:(NSDictionary*)dict
{
    
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    VKPhoto *photo = [[VKPhoto alloc] initWithID:[dict objectForKey:@"id"]];
    photo.date = [NSDate dateWithTimeIntervalSince1970:[dict integerForKey:@"date"]];
    photo.caption = [dict objectForKey:@"caption"];
    // TODO: store all size info
    NSArray *sizes = [dict objectForKey:@"sizes"];
    // TODO: helpers for JK collections
    photo.imageURL = [NSURL URLWithString:[[sizes lastObject] objectForKey:@"location"]];
    photo.thumbnailURL = [NSURL URLWithString:[[sizes objectAtIndex:0] objectForKey:@"location"]];
    return photo;
}

- (RemoteImage*)photo
{
    return [[ImageCache shared] remoteImageForURL:imageURL];
}

- (RemoteImage*)thumbnail
{
    return [[ImageCache shared] remoteImageForURL:thumbnailURL];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: url:'%@' date:'%@' caption:'%@'>", NSStringFromClass(self.class), imageURL, date, caption];
}
@end
