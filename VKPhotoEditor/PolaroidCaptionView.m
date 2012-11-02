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
@synthesize captionLabel;
@synthesize delegate;

#pragma mark - CaptionTemplateProtocol

- (NSString*)text
{
    return captionLabel.text;
}

- (void)setText:(NSString *)_text
{
    captionLabel.text = _text;
}

- (void)setFont:(UIFont *)_font
{
    captionLabel.font = [_font fontWithSize:captionLabel.font.pointSize];
}

- (UIFont*)font
{
    return captionLabel.font;
}

- (UIColor *)textColor
{
    return captionLabel.textColor;
}

- (UIImage *)templateImage
{
    return templateImageView.image;
}

@end
