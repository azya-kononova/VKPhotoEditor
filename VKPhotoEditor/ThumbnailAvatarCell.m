//
//  ThumbnailAvatarCell.m
//  VKPhotoEditor
//
//  Created by Kate on 12/9/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailAvatarCell.h"
#import "ThumbnailAvatarView.h"

@interface ThumbnailAvatarCell () <ThumbnailAvatarViewDelegate>
@end

@implementation ThumbnailAvatarCell
@synthesize delegate;

- (void)displayPhotos:(NSArray *)photos
{
    for (NSUInteger i = 0; i < self.photoViews.count; ++i) {
        ThumbnailAvatarView *avatarView = [self.photoViews objectAtIndex:i];
        
        if (i < photos.count) {
            avatarView.hidden = NO;
            avatarView.delegate = self;
            [avatarView displayAccount:[photos objectAtIndex:i]];
        } else {
            avatarView.hidden = YES;
        }
    }
}

#pragma mark - ThumbnailAvatarViewDelegate

- (void)thumbnailAvatarView:(ThumbnailAvatarView *)view didSelectAccount:(Account *)account
{
    [delegate thumbnailAvatarCell:self didSelectAccount:account];
}

@end
