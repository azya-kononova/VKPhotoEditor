//
//  ThumbnailAvatarView.h
//  VKPhotoEditor
//
//  Created by Kate on 12/9/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
#import "Account.h"

@protocol ThumbnailAvatarViewDelegate;

@interface ThumbnailAvatarView : UIView
@property (nonatomic, assign) IBOutlet id<ThumbnailAvatarViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

- (void)displayAccount:(Account*)account;
@end

@protocol ThumbnailAvatarViewDelegate
- (void)thumbnailAvatarView:(ThumbnailAvatarView *)view didSelectAccount:(Account *)account;
@end
