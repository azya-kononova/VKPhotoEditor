//
//  UIImage+Blending.m
//  VKPhotoEditor
//
//  Created by asya on 11/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+Blending.h"
#import "GPUImageNormalBlendFilter.h"
#import "GPUImagePicture.h"

@implementation UIImage (Blending)

- (UIImage *)blendWithImage:(UIImage *)image
{
    GPUImageNormalBlendFilter *blendFilter = [GPUImageNormalBlendFilter new];
    
    GPUImagePicture *firstPic = [[GPUImagePicture alloc] initWithImage:self];
    GPUImagePicture *secondPic = [[GPUImagePicture alloc] initWithImage:image];
    
    [firstPic addTarget:blendFilter];
    [firstPic processImage];
    [secondPic addTarget:blendFilter];
    [secondPic processImage];
    
    return [blendFilter imageFromCurrentlyProcessedOutputWithOrientation:self.imageOrientation];
}

@end
