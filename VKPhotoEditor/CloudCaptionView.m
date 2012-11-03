//
//  CloudOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CloudCaptionView.h"

@interface CloudCaptionView () {
    IBOutlet UIImageView *templateImageView;
}
@end

@implementation CloudCaptionView

#pragma mark - CaptionTemplateProtocol


- (UIColor *)textColor
{
    return [UIColor blackColor];
}

- (UIImage *)templateImage
{
    return templateImageView.image;
}

@end

