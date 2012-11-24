//
//  LoadedPhotoCell.h
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIBLoaderView.h"

@interface ThumbnailPhotoCell : UITableViewCell<XIBLoaderViewDelegate>

//TODO: search string
@property (nonatomic, assign, readonly) NSInteger itemsInRow;

- (void)displayPhotos:(NSArray *)photos;

@end
