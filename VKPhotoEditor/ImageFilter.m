//
//  ImageFilter.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ImageFilter.h"

@implementation ImageFilter
@synthesize previewPath;
@synthesize name;

- (id)initWithPreviewPath:(NSString*)_previewPath name:(NSString *)_name
{
    if (self = [super init]) {
        previewPath = _previewPath;
        name = _name;
    }
    return self;
}
@end
