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
@synthesize fragmentShaderPaths;
@synthesize vertexShaderPaths;

- (id)initWithPreviewPath:(NSString*)_previewPath fragmentShaderPaths:(NSArray*)_fsPaths vertexShaderPaths:(NSArray*)_vsPaths
{
    if (self = [super init]) {
        previewPath = _previewPath;
        fragmentShaderPaths = _fsPaths;
        vertexShaderPaths = _vsPaths;
    }
    return self;
}
@end
