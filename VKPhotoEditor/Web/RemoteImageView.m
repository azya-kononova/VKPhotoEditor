//
//  RemoteImageView.m
//  Radario
//
//  Created by Sergey Martynov on 27.01.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "RemoteImageView.h"
#import "CALayer+Animations.h"
#import "UIView+Helpers.h"

@implementation RemoteImageView {
    CGFloat totalProgressWidth;
}
@synthesize image;
@synthesize imageView;
@synthesize placeholder;
@synthesize isCircular;
@synthesize delegate;
@synthesize progressView;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        totalProgressWidth = progressView.frame.size.width;
    }
    return self;
}

- (void)awakeFromNib
{
    totalProgressWidth = progressView.frame.size.width;
    progressView.layer.cornerRadius = 6;
    placeholder.layer.cornerRadius = 6;
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
    
    if (_image && [delegate respondsToSelector:@selector(remoteImageView:didLoadImage:)]) {
        [delegate remoteImageView:self didLoadImage:_image];
    }
}

- (void)setProgress:(float)progress
{
    [progressView resizeTo:CGSizeMake(totalProgressWidth * progress, progressView.frame.size.height)];
}

- (void)displayImage:(RemoteImage*)_image
{
    [image removeObserver:self forKeyPath:@"progress"];
    [image addObserver:self forKeyPath:@"isLoad" options:0 context:NULL];
    
    image = _image;
    
    [image addObserver:self forKeyPath:@"progress" options:0 context:NULL];
    [image addObserver:self forKeyPath:@"isLoad" options:0 context:NULL];
    
    [self _displayImage:image.image];
    
    [self setProgress:_image.image ? 1.0 : 0.0];
    [image startLoading];
}

- (void)dealloc
{
    [image removeObserver:self forKeyPath:@"isLoad"];
    [image removeObserver:self forKeyPath:@"progress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"progress"]) {
        [self setProgress:image.progress];
    }
    if([keyPath isEqualToString:@"isLoad"]) {
        [self _displayImage:image.image];
    }
}

@end
