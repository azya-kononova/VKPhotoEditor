//
//  PhotoCell.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoCell.h"
#import "CALayer+Animations.h"

@implementation PhotoCell {
    VKPhoto *photo;
}
@synthesize remoteImageView;
@synthesize addedImageView;

- (void)displayPhoto:(VKPhoto *)_photo
{
    photo = _photo;
    [remoteImageView displayImage:photo.photo];
}

- (void)hideSelfAfterTimeout:(NSTimeInterval)timeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (timeout > 0) {
        [self performSelector:@selector(hideSelf) withObject:nil afterDelay:timeout];
    }
}

- (void)showAdded;
{
    [self showSelf:YES];
    [self hideSelfAfterTimeout:3.5];
}

- (void)showSelf:(BOOL)show
{
    [addedImageView.layer fade].duration = 0.5;
    addedImageView.hidden = !show;
}

- (void)hideSelf
{
    [self showSelf:NO];
}

#pragma mark - RemoteImageViewDelegate

- (void)remoteImageView:(RemoteImageView*)view didLoadImage:(UIImage *)image
{
    if (photo.justUploaded) {
        [self showAdded];
        photo.justUploaded = NO;
    }
}

@end