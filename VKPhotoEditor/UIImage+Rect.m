//
//  UIImage+Rect.m
//  VKPhotoEditor
//
//  Created by asya on 9/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+Rect.h"

@implementation UIImage (Rect)


- (CGRect)rectInImage:(CGRect)bounds
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

@end
