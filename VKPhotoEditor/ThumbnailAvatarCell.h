//
//  ThumbnailAvatarCell.h
//  VKPhotoEditor
//
//  Created by Kate on 12/9/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailPhotoCell.h"

@protocol ThumbnailAvatarCellDelegate;

@interface ThumbnailAvatarCell : ThumbnailPhotoCell
@property (nonatomic, assign) id<ThumbnailPhotoCellDelegate, ThumbnailAvatarCellDelegate> delegate;
@end

@protocol ThumbnailAvatarCellDelegate
- (void)thumbnailAvatarCell:(ThumbnailAvatarCell*)cell didSelectAccount:(Account*)account;
@end