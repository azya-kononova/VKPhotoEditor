//
//  FlashMode.m
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FlashMode.h"

@implementation FlashMode

@synthesize image, name, mode;

- (id)initWithMode:(NSInteger)_mode name:(NSString *)_name imageName:(NSString *)_imageName
{
    self = [super init];
    if (self) {
        mode = _mode;
        name = _name;
        image = [UIImage imageNamed:_imageName];
    }
    return self;
}

FlashMode *MakeFlashMode(NSInteger _mode, NSString *_name, NSString *_imageName)
{
    return [[FlashMode alloc] initWithMode:_mode name:_name imageName:_imageName];
}

@end
