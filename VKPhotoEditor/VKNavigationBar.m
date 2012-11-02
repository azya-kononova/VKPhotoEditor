//
//  VKNavigationBar.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKNavigationBar.h"

@implementation VKNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed: @"MainHeader.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
