//
//  PhotoEditController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

@class FlexibleButton;
@class ThumbnailsView;

@interface PhotoEditController : UIViewController
@property (nonatomic, strong) IBOutlet FlexibleButton *saveButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *retakeButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *captionButton;
@property (nonatomic, strong) IBOutlet ThumbnailsView *filterView;
- (IBAction)addCaption;
@end
