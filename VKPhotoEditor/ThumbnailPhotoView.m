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
}
@synthesize remoteImageView;
@synthesize captionTextView;
@synthesize searchString;

- (void)awakeFromNib
{
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:12.0];
}

- (void)displayPhoto:(VKPhoto *)_photo
{
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
    
}

@end
