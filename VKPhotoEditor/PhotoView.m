//
//  AvatarView.m
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoView.h"
#import "UITextView+Resize.h"

@implementation PhotoView
@synthesize remoteImageView;
@synthesize captionTextView;

- (void)awakeFromNib
{
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:28.0];
}

- (void)displayPhoto:(VKPhoto *)photo
{
//    TODO: think about image aspect
    [remoteImageView displayImage:photo.photo];
    if (![photo.caption isKindOfClass:[NSNull class]]) captionTextView.text = photo.caption ;
    [captionTextView sizeFontToFitMinSize:8 maxSize:28];
    [captionTextView setNeedsDisplay];
}

@end
