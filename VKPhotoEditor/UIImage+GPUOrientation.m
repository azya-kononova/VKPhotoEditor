//
//  UIImage+GPUOrientation.m
//  VKPhotoEditor
//
//  Created by asya on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+GPUOrientation.h"

@implementation UIImage (GPUOrientation)

- (GPUImageRotationMode)rotationMode
{
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
            return kGPUImageNoRotation;
        case UIImageOrientationLeft:
            return kGPUImageRotateLeft;
        case UIImageOrientationRight:
            return kGPUImageRotateRight;
        case UIImageOrientationDown:
            return kGPUImageRotate180;
        case UIImageOrientationLeftMirrored:
            return kGPUImageFlipVertical;
        case UIImageOrientationRightMirrored:
            return kGPUImageRotateRightFlipVertical;
        case UIImageOrientationDownMirrored:
            return kGPUImageFlipHorizonal;
        case UIImageOrientationUpMirrored:
            return kGPUImageFlipHorizonal;
        default:
            return kGPUImageNoRotation;
    }
}

@end
