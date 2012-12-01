//
//  ImageToUpload.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ImageToUpload.h"

@implementation ImageToUpload
@synthesize image;
@synthesize caption;
@synthesize replyToUser;
@synthesize replyToPhoto;
@synthesize replyToFeed;

ImageToUpload *ImageToUploadMake(UIImage *image, NSString *caption, NSString *replyToUser, NSString *replyToPhoto, NSNumber *replyToFeed)
{
    ImageToUpload *img = [ImageToUpload new];
    img.image = image;
    img.caption = caption;
    img.replyToUser = replyToUser;
    img.replyToPhoto = replyToPhoto;
    img.replyToFeed = replyToFeed;
    
    return img;
}

- (BOOL)isAvatar
{
    return caption.length >= 3 && [[caption substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"#me"];
}

- (NSString *)caption
{
    return replyToPhoto && replyToUser ? [[NSString stringWithFormat:@"@%@ ", replyToUser] stringByAppendingString:caption] : caption;
}

- (NSNumber *)replyToFeed
{
    return replyToPhoto && replyToUser ? replyToFeed : nil;
}

- (NSString *)replyToPhoto
{
    return replyToUser ? replyToPhoto : nil;
}

@end
