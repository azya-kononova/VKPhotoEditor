//
//  UIButton+StateImage.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIButton+StateImage.h"

@implementation UIButton (StateImage)

- (void)setDefaultImage:(UIImage*)image higthligted:(UIImage*)hImage
{
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:hImage forState:UIControlStateHighlighted];
}

@end
