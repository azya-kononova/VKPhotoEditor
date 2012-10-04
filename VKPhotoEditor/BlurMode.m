//
//  BlurMode.m
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "BlurMode.h"

@implementation BlurMode

@synthesize iconImage, image, mode;

- (id)initWithMode:(NSInteger)_mode imageName:(NSString *)_imageName iconImageName:(NSString *)_iconImageName
{
    self = [super init];
    if (self) {
        mode = _mode;
        image = [UIImage imageNamed:_imageName];
        iconImage = [UIImage imageNamed:_iconImageName];
    }
    return self;
}

BlurMode *MakeBlurMode(NSInteger _mode, NSString *_imageName, NSString *_iconImageName)
{
    return [[BlurMode alloc] initWithMode:_mode imageName:_imageName iconImageName:_iconImageName];
}

@end
