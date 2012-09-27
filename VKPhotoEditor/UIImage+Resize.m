//
//  UIImage+Resize.h
//  VKPhotoEditor
//
//  Created by asya on 9/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)croppedImage:(CGRect)bounds
{
    CGRect rect = CGRectZero;
    
    switch (self.imageOrientation) {
        case UIImageOrientationRight:
            rect = CGRectMake(bounds.origin.y, self.size.width - bounds.origin.x - bounds.size.width, bounds.size.height, bounds.size.width);
            break;
        case UIImageOrientationLeft:
            rect = CGRectMake(self.size.height - bounds.origin.y - bounds.size.height, bounds.origin.x, bounds.size.width, bounds.size.height);
            break;
        case UIImageOrientationDown:
            rect = CGRectMake(self.size.width - bounds.origin.x - bounds.size.width, self.size.height - bounds.origin.y - bounds.size.height, bounds.size.height, bounds.size.width);
            break;
        default:
            rect = bounds;
            break;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}


@end