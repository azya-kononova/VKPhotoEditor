//
//  MyButton.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "HighlightedButton.h"

@implementation HighlightedButton
@synthesize delegate;

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.highlighted != highlighted) [delegate highlightedButton:self didBecameHighlighted:highlighted];
    [super setHighlighted:highlighted];
}

@end
