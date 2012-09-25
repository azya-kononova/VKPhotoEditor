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
    return CGRectInset(bounds, 7, 2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
