//
//  PolaroidOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PolaroidCaptionView.h"
#import "UIView+Helpers.h"

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
    captionLabel.font = [UIFont fontWithName:_font.fontName size:captionLabel.font.pointSize];
}

- (UIFont*)font
{
    return captionLabel.font;
}

@end
