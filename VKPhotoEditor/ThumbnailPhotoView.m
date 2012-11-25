//
//  LoadedPhotoView.m
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailPhotoView.h"
#import "UITextView+Resize.h"

@implementation ThumbnailPhotoView{
    VKPhoto *photo;
    BOOL isBigImageLoading;
}
@synthesize remoteImageView;
@synthesize captionTextView;
@synthesize searchString;
@synthesize delegate;

- (void)awakeFromNib
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:recognizer];
    
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:12.0];
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(-2, -2);
    self.layer.shadowRadius = 1.3;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width + 4, self.bounds.size.height + 4)].CGPath;
}

- (void)didTap:(UITapGestureRecognizer *)recognizer
{
    isBigImageLoading = YES;
    [remoteImageView loadImage:photo.photo showProgressBar:YES];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
    isBigImageLoading = NO;
    
    self.hidden = _photo.imageURL == nil;
    photo = _photo;
    [remoteImageView displayImage:photo.thumbnail];
    if (![photo.caption isKindOfClass:[NSNull class]]) captionTextView.text = photo.caption;
    [captionTextView sizeFontToFitMinSize:8 maxSize:12];
    captionTextView.searchString = searchString;
    [captionTextView setNeedsDisplay];
}


#pragma mark - RemoteImageViewDelegate

- (void)remoteImageView:(RemoteImageView*)view didLoadImage:(UIImage *)image
{
    if (isBigImageLoading) {
        [delegate thumbnailPhotoView:self didSelectPhoto:photo];
    }
}

@end
