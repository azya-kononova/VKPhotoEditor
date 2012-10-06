//
//  UIImage+Rect.m
//  VKPhotoEditor
//
//  Created by asya on 9/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+Rect.h"

@implementation UIImage (Rect)

- (CGRect)rotateRectInImage:(CGRect)bounds
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
    
    return rect;
}

- (CGRect)orientedRect:(CGRect)rect
{
    if ([self hasLandscapeOrientation]) {
        CGRect landscapeRect = rect;
        landscapeRect.size.width = rect.size.height;
        landscapeRect.size.height = rect.size.width;
        
        return landscapeRect;
    }
    
    return rect;
}

- (BOOL)hasLandscapeOrientation
{
    return self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored ||
            self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored;
}

@end
