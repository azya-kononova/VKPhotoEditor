//
//  CloudOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CloudCaptionView.h"
#import "UILabel+Multiline.h"

@interface CloudCaptionView () <SPUserResizableViewDelegate>
@end

@implementation CloudCaptionView
@synthesize captionLabel;
@synthesize delegate;
@synthesize labelView;

#pragma mark - CaptionTemplateProtocol

- (NSString*)text
{
    return captionLabel.text;
}

- (void)setText:(NSString *)_text
{
    captionLabel.text = _text;
    [UILabel resizeFontForLabel:captionLabel maxSize:150 minSize:10];
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
    return nil;
}

#pragma mark - SPUserResizableViewDelegate

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView
{
    [delegate captionTemplateStartEditing:self];
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
    [delegate captionTemplateEndEditing:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [UILabel resizeFontForLabel:captionLabel maxSize:150 minSize:10];
}

@end

