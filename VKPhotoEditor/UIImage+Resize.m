//
//  UIImage+Resize.h
//  VKPhotoEditor
//
//  Created by asya on 9/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+Resize.h"
#import "UIImage+Rect.h"

@implementation UIImage (Resize)

- (UIImage *)croppedImage:(CGRect)bounds
{
    CGRect rect = [self rotateRectInImage:bounds];
    CGRect absRect = CGRectMake(fmaxf(0, rect.origin.x), fmaxf(0, rect.origin.y), rect.size.width, rect.size.height);
    
    if (self.size.height < bounds.size.height || self.size.width < bounds.size.width) {
        return [self croppedRectImage:absRect];
    } else {
        return [self croppedSquareImage:absRect];
    }  
}

- (UIImage *)croppedRectImage:(CGRect)bounds
{
    CGFloat width = fminf(bounds.size.width, self.size.width);
    CGFloat height = fminf(bounds.size.height, self.size.height);
    CGRect rect = rect = CGRectMake(bounds.origin.x, bounds.origin.y, width, height);
    
    UIImage *croppedImage = [self croppedSquareImage:[self orientedRect:rect]];
    
    UIGraphicsBeginImageContext(bounds.size);
    
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)); 
    
    [croppedImage drawInRect:CGRectMake((bounds.size.width - width)/2, (bounds.size.height - height)/2, width, height) blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)croppedSquareImage:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:self.imageOrientation];
    CGImageRelease(imageRef);

    return croppedImage;
}

@end