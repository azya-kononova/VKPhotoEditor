//
//  PhotoCell.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
#import "VKPhoto.h"
#import "VKHighlightTextView.h"

@protocol PhotoCellDelegate;

@interface PhotoCell : UITableViewCell
@property (nonatomic, assign) id<PhotoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet UIImageView *addedImageView;
@property (nonatomic, strong) IBOutlet VKHighlightTextView *captionTextView;

- (void)displayPhoto:(VKPhoto*)photo;
@end

@protocol PhotoCellDelegate <NSObject>
- (void)photoCell:(PhotoCell*)photoCell didTapHashTag:(NSString*)hashTag;
@end