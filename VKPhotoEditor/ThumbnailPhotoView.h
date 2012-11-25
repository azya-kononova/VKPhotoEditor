//
//  LoadedPhotoView.h
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
#import "VKPhoto.h"
#import "VKHighlightTextView.h"

@protocol ThumbnailPhotoViewDelegate;

@interface ThumbnailPhotoView : UIView

@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet VKHighlightTextView *captionTextView;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, unsafe_unretained) id<ThumbnailPhotoViewDelegate> delegate;

- (void)displayPhoto:(VKPhoto*)photo;

@end

@protocol ThumbnailPhotoViewDelegate
- (void)thumbnailPhotoView:(ThumbnailPhotoView *)view didSelectPhoto:(VKPhoto *)photo;
@end