//
//  FlexibleTextField.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FlexibleTextField.h"

@implementation FlexibleTextField {
    BOOL backgroundReady;
}
@synthesize horizontalPadding, verticalPadding;

- (void)layoutSubviews
{
    if (!backgroundReady) {
        self.background = [self.background stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        backgroundReady = YES;
    }
    [super layoutSubviews];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + horizontalPadding, bounds.origin.y + verticalPadding, bounds.size.width - horizontalPadding, bounds.size.height - verticalPadding*2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
