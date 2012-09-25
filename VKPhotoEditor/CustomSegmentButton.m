//
//  CustomSegmentButton.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CustomSegmentButton.h"

@implementation CustomSegmentButton

-(id)initWithNormalImage:(UIImage*)normal selectedImage:(UIImage*)selected size:(CGSize)size
{
    if (self =  [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        [self setBackgroundImage:normal forState:UIControlStateNormal];
        [self setBackgroundImage:selected forState:UIControlStateSelected];
        self.selected = NO;
    };
	return self;
}

@end
