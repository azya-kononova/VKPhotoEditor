//
//  LoadedPhotoCell.h
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIBLoaderView.h"
#import "VKPhoto.h"

@protocol ThumbnailPhotoCellDelegate;

@interface ThumbnailPhotoCell : UITableViewCell<XIBLoaderViewDelegate>

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, assign, readonly) NSInteger itemsInRow;
@property (nonatomic, unsafe_unretained) id<ThumbnailPhotoCellDelegate> delegate;

- (void)displayPhotos:(NSArray *)photos;

@end

@protocol ThumbnailPhotoCellDelegate
- (void)thumbnailPhotoCell:(ThumbnailPhotoCell *)cell didSelectPhoto:(VKPhoto *)photo;
@end
