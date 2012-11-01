//
//  UIImage+Blend.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIImage+Blend.h"
#import "UIView+Helpers.h"

@implementation UIImage (Blend)

- (UIImage*)squareImageByBlendingWithView:(UIView*)view
{
//    if (!view && abs(self.size.width - self.size.height) <= 1) return self;
    
    CGFloat side = fmaxf(self.size.width, self.size.height);

    CGRect rect = CGRectMake(0, 0, side, side);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    [[UIColor blackColor] set];
    UIRectFill(rect);
    [self drawInRect:CGRectMake((side - self.size.width)/2, (side - self.size.height)/2, self.size.width, self.size.height)];
    if (view) [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
