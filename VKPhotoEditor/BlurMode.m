//
//  BlurMode.m
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "BlurMode.h"

@implementation BlurMode

@synthesize iconImage, image, filter;

- (id)initWithFilter:(GPUImageOutput <GPUImageInput> *)_filter imageName:(NSString *)_imageName iconImageName:(NSString *)_iconImageName
{
    self = [super init];
    if (self) {
        filter = _filter;
        image = [UIImage imageNamed:_imageName];
        iconImage = [UIImage imageNamed:_iconImageName];
    }
    return self;
}

BlurMode *MakeBlurMode(GPUImageOutput <GPUImageInput> *_filter, NSString *_imageName, NSString *_iconImageName)
{
    return [[BlurMode alloc] initWithFilter:_filter imageName:_imageName iconImageName:_iconImageName];
}

@end
