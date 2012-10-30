//
//  RemoteImageView.m
//  Radario
//
//  Created by Sergey Martynov on 27.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "RemoteImageView.h"
#import "CALayer+Animations.h"

@implementation RemoteImageView
@synthesize image;
@synthesize imageView;
@synthesize placeholder;
@synthesize isCircular;
@synthesize delegate;

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window) {
        [image startLoading];
    }
}

- (void)_displayImage:(UIImage*)_image
{
    BOOL animated = !imageView.image;
    
    if (animated) {
        [self.layer fade].duration = 0.75;
        [imageView.layer fade].duration = 0.75;
    }
    self.placeholder.hidden = _image != nil;
    imageView.hidden = _image == nil;
    imageView.image = _image;
    
    if (isCircular) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.frame.size.width / 2;
    }
    
    if (image && [delegate respondsToSelector:@selector(remoteImageView:didLoadImage:)]) {
        [delegate remoteImageView:self didLoadImage:_image];
    }
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
