//
//  ChoosePhotoView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FlexibleButton.h"
#import "VKPhoto.h"
#import "RemoteImageView.h"

@protocol  ChoosePhotoViewDelegate;

@interface ChoosePhotoView : UIView
@property (nonatomic, assign) id<ChoosePhotoViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet FlexibleButton *takePhotoButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *exitButton;
@property (nonatomic, strong) IBOutlet UIView *libraryPlaceholder;
@property (nonatomic, strong) IBOutlet UIView *replyView;
@property (nonatomic, strong) IBOutlet RemoteImageView *replyImageView;
@property (nonatomic, strong) IBOutlet UILabel *replyLabel;
@property (nonatomic, strong) IBOutlet UIButton *cameraRollButton;
@property (nonatomic, strong) IBOutlet UIView *bgTextureView;

- (IBAction)cameraRoll;
- (IBAction)takePhoto;
- (IBAction)cancel;
- (IBAction)exit;

- (void)show:(BOOL)show animated:(BOOL)animated;
- (void)show:(BOOL)show replyToPhoto:(VKPhoto *)photo animated:(BOOL)animated;
- (void)show:(BOOL)show withExitButton:(BOOL)needExitButton animated:(BOOL)animated;

@end

@protocol ChoosePhotoViewDelegate
- (void)choosePhotoViewDidChooseCameraRoll:(ChoosePhotoView*)view;
- (void)choosePhotoView:(ChoosePhotoView*)view didChooseImage:(UIImage*)image;
- (void)choosePhotoViewDidChooseCamera:(ChoosePhotoView*)view;
- (void)choosePhotoViewDidCancel:(ChoosePhotoView*)view;
- (void)choosePhotoViewDidExit:(ChoosePhotoView*)view;
@end
