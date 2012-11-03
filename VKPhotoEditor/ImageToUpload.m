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

+ (ImageToUpload*)imageWithImage:(UIImage*)image caption:(NSString*)caption
{
    ImageToUpload *img = [ImageToUpload new];
    img.image = image;
    img.caption = caption;
    
    return img;
}

@end
