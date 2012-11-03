//
//  BlurMode.m
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "BlurMode.h"
#import "Filters.h"

@implementation BlurMode {
    NSString *filterName;
}

@synthesize iconImage, image, filter, hasFilter;

- (id)initWithFilter:(NSString *)_filterName imageName:(NSString *)_imageName iconImageName:(NSString *)_iconImageName
{
    self = [super init];
    if (self) {
        filterName = _filterName;
        image = [UIImage imageNamed:_imageName];
        iconImage = [UIImage imageNamed:_iconImageName];
        hasFilter = filterName.length;
    }
    return self;
}

BlurMode *MakeBlurMode(NSString *_filterName, NSString *_imageName, NSString *_iconImageName)
{
    return [[BlurMode alloc] initWithFilter:_filterName imageName:_imageName iconImageName:_iconImageName];
}

- (GPUImageOutput <GPUImageInput> *)filter
{
    return filterName ? [Filters GPUFilterWithName:filterName] : nil;
}

@end
