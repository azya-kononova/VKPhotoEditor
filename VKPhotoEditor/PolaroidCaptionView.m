//
//  PolaroidOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PolaroidCaptionView.h"
#import "UIView+Helpers.h"

@interface PolaroidCaptionView () {
    IBOutlet UIImageView *templateImageView;
}
@end

@implementation PolaroidCaptionView

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
