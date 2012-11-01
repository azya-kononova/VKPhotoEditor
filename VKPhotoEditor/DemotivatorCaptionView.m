//
//  DemotivatorOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "DemotivatorCaptionView.h"

@implementation DemotivatorCaptionView
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

@end
