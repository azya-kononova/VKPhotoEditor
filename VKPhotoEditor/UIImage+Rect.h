//
//  UIImage+Rect.h
//  VKPhotoEditor
//
//  Created by asya on 9/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rect)

- (CGRect)rotateRectInImage:(CGRect)rect;
- (CGRect)orientedRect:(CGRect)rect;

@end
