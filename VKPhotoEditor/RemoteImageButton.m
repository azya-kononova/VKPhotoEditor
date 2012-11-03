//
//  RemoteImageButton.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RemoteImageButton.h"
#import "CALayer+Animations.h"

@implementation RemoteImageButton
@synthesize image;

- (void)_displayImage:(UIImage*)_image
{
    if (!_image) return;
    [self.layer fade].duration = 0.75;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 3;
    
    [self setImage:_image forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];
}

- (void)displayImage:(RemoteImage*)_image
{
    image.delegate = nil;
    [image removeObserver:self forKeyPath:@"isLoad"];
    image = _image;
    [image addObserver:self forKeyPath:@"isLoad" options:0 context:NULL];
    [self _displayImage:image.image];
    [image startLoading];
}

- (void)dealloc
{
    [image removeObserver:self forKeyPath:@"isLoad"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"isLoad"]) {
        [self _displayImage:image.image];
    }
}

@end
