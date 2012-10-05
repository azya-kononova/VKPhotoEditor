//
//  PhotoEditController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FlexibleButton.h"
#import "ThumbnailsView.h"
#import "GPUImageView.h"
#import "SPUserResizableView.h"

@protocol PhotoEditControllerDelegate;

@interface PhotoEditController : UIViewController
@property (nonatomic, strong) IBOutlet FlexibleButton *saveButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *retakeButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *captionButton;
@property (nonatomic, strong) IBOutlet ThumbnailsView *filterView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet GPUImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet SPUserResizableView *labelView;
@property (nonatomic, strong) IBOutlet UILabel *captionLabel;

@property (nonatomic, unsafe_unretained) id<PhotoEditControllerDelegate> delegate;

- (id)initWithImage:(UIImage *)_image filterIndex:(NSInteger)_filterIndex;
- (IBAction)addCaption;
- (IBAction)save;
- (IBAction)editLabel;
@end

@protocol PhotoEditControllerDelegate
- (void)photoEditControllerDidCancel:(PhotoEditController *)controller;
- (void)photoEditControllerDidRetake:(PhotoEditController *)controller;
@end
