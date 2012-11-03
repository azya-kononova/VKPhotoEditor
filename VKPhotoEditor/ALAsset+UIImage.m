//
//  ALAsset+UIImage.m
//  VKPhotoEditor
//
//  Created by asya on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ALAsset+UIImage.h"

@implementation ALAsset (UIImage)

- (UIImage *)image
{
    ALAssetRepresentation *representation = [self defaultRepresentation];
    return [UIImage imageWithCGImage:[representation fullScreenImage]];
}

@end
