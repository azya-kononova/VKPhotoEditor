//
//  LoadedPhotoView.m
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailPhotoView.h"
#import "UITextView+Resize.h"
#import "ImageCache.h"
#import "UIView+Helpers.h"

@interface ThumbnailPhotoView ()<RemoteImageDelegate>
@end

@implementation ThumbnailPhotoView{
    VKPhoto *photo;
    RemoteImage *largePhotoImage;
    CGFloat totalProgressWidth;
}

@synthesize remoteImageView;
@synthesize captionTextView;
@synthesize searchString;
@synthesize delegate;
@synthesize placeholderView;
@synthesize progressView;

- (void)awakeFromNib
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:recognizer];
    
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:12.0];
    
    totalProgressWidth = progressView.frame.size.width;
    progressView.layer.cornerRadius = 6;
    placeholderView.layer.cornerRadius = 6;
}

- (void)didTap:(UITapGestureRecognizer *)recognizer
{
    [largePhotoImage removeObserver:self forKeyPath:@"progress"];
    
    largePhotoImage = [[ImageCache shared] remoteImageForURL:photo.imageURL];
    largePhotoImage.delegate = self;
    
    [largePhotoImage addObserver:self forKeyPath:@"progress" options:0 context:NULL];
    
    [largePhotoImage startLoading];
    placeholderView.hidden = !photo.isPhotoLoading;
    [self setProgress:largePhotoImage.image ? 1.0 : 0.0];
    
    if (largePhotoImage.image) {
        [delegate thumbnailPhotoView:self didSelectPhoto:photo];
    }
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    photo = _photo;
    
    self.hidden = photo.thumbnailURL == nil;
    [remoteImageView displayImage:photo.thumbnail];
    
    if (![photo.caption isKindOfClass:[NSNull class]]) captionTextView.text = photo.caption;
    captionTextView.searchString = searchString;
    [captionTextView setNeedsDisplay];
    
    placeholderView.hidden = !photo.isPhotoLoading;
}

- (void)setProgress:(float)progress
{
    [progressView resizeTo:CGSizeMake(totalProgressWidth * progress, progressView.frame.size.height)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"progress"]) {
        [self setProgress:largePhotoImage.progress];
    }
}

- (void)dealloc
{
    [largePhotoImage removeObserver:self forKeyPath:@"progress"];
}

#pragma mark - RemoteImageViewDelegate

- (void)remoteImageView:(RemoteImageView*)view didLoadImage:(UIImage *)image
{
    
}

#pragma mark - RemoteImageDelegate

- (void)remoteImageDidFinishLoading:(RemoteImage *)remoteImage
{
    placeholderView.hidden = !photo.isPhotoLoading;
    [delegate thumbnailPhotoView:self didSelectPhoto:photo];
}

- (void)remoteImage:(RemoteImage *)remoteImage loadingFailedWithError:(NSError *)error
{
    //TODO:
    NSLog(@"The error is ocured");
}

@end
