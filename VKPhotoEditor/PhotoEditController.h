//
//  PhotoEditController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

@class FlexibleButton;
@class ThumbnailsView;

@protocol PhotoEditControllerDelegate;

@interface PhotoEditController : UIViewController
@property (nonatomic, strong) IBOutlet FlexibleButton *saveButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *retakeButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *captionButton;
@property (nonatomic, strong) IBOutlet ThumbnailsView *filterView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *topView;

@property (nonatomic, unsafe_unretained) id<PhotoEditControllerDelegate> delegate;

- (id)initWithImage:(UIImage *)image isPhoto:(BOOL)isPhoto;
- (IBAction)addCaption;
@end

@protocol PhotoEditControllerDelegate
- (void)photoEditControllerDidCancel:(PhotoEditController *)controller;
- (void)photoEditControllerDidRetake:(PhotoEditController *)controller;
@end
