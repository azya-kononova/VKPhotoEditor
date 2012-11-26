//
//  LibraryPhotosView.h
//  VKPhotoEditor
//
//  Created by asya on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LibraryPhotosViewDelegate;

@interface LibraryPhotosView : UIView

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, unsafe_unretained) id<LibraryPhotosViewDelegate> delegate;

- (void)reloadData;
- (void)clear;

@end

@protocol LibraryPhotosViewDelegate
- (void)libraryPhotoView:(LibraryPhotosView *)view didTapOnImage:(UIImage *)image;
@end
