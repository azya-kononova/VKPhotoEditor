//
//  RemoteImageView.m
//  Radario
//
//  Created by Sergey Martynov on 27.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "RemoteImageView.h"
#import "CALayer+Animations.h"

@interface RemoteImageView () <RemoteImageDelegate>
@end

@implementation RemoteImageView
@synthesize image;
@synthesize imageView;
@synthesize placeholder;
@synthesize isCircular;

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
        [self.layer fade];
        [imageView.layer fade];
    }
    placeholder.hidden = _image != nil;
    imageView.hidden = _image == nil;
    imageView.image = _image;
    
    if (isCircular) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.frame.size.width / 2;
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


- (void)remoteImageDidFinishLoading:(RemoteImage*)remoteImage
{
    if (image == remoteImage) {
        [self _displayImage:remoteImage.image];
    }
}

- (void)remoteImage:(RemoteImage*)remoteImage loadingFailedWithError:(NSError*)error
{
    NSLog(@"Failed to load remote image from '%@': %@", remoteImage.imageUrl, error);
}

@end
