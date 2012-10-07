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
    captionLabel.font = [UIFont fontWithName:_font.fontName size:captionLabel.font.pointSize];
}

- (UIFont*)font
{
    return captionLabel.font;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
