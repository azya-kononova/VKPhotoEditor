//
//  UIColor+VKPhotoEditor.m
//  VKPhotoEditor
//
//  Created by DeveloEkaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UIColor+VKPhotoEditor.h"

@implementation UIColor (VKPhotoEditor)

+ (UIColor*)defaultBgColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackGround.png"]];
}

+ (UIColor*)tabBarBgColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bottom.png"]];
}
@end
