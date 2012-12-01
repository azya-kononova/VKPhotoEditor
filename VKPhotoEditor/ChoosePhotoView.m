//
//  ChoosePhotoView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ChoosePhotoView.h"
#import "UIColor+VKPhotoEditor.h"
#import "UIView+Helpers.h"
#import "CALayer+Animations.h"
#import "LibraryPhotosView.h"
#import "UIColor+VKPhotoEditor.h"

@interface ChoosePhotoView ()<LibraryPhotosViewDelegate>
@end

@implementation ChoosePhotoView {
    LibraryPhotosView *libraryPhotosView;
}

@synthesize overlayView;
@synthesize bgView;
@synthesize takePhotoButton;
@synthesize cancelButton;
@synthesize exitButton;
@synthesize libraryPlaceholder;
@synthesize delegate;
@synthesize replyImageView;
@synthesize replyLabel;
@synthesize replyView;
@synthesize cameraRollButton;
@synthesize bgTextureView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    libraryPhotosView = [LibraryPhotosView loadFromNIB];
    libraryPhotosView.delegate = self;
    [libraryPlaceholder addSubview:libraryPhotosView];
    
    bgTextureView.backgroundColor = [UIColor defaultBgColor];
    
    takePhotoButton.bgImagecaps = CGSizeMake(20, 20);
    cancelButton.bgImagecaps = CGSizeMake(20, 20);
    takePhotoButton.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    replyLabel.font = [UIFont fontWithName:@"Lobster" size:22.0];
    replyLabel.backgroundColor = [UIColor defaultBgColor];
    replyImageView.layer.masksToBounds = YES;
    replyImageView.layer.cornerRadius = 6;
    
    [self show:NO animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show:(BOOL)show withExitButton:(BOOL)needExitButton replyPhoto:(VKPhoto *)photo animated:(BOOL)animated
{
    BOOL isReply = photo != nil;
    
    exitButton.hidden = !needExitButton;
    replyView.hidden = !isReply;
    
    [replyImageView displayImage:photo.photo];
    
    [self resetCameraRollButtonWithReply:isReply];
    
    if (show) [libraryPhotosView reloadData];
    
    if (animated) {
        if (show) self.hidden = NO;
        [overlayView.layer fade];
        
        CATransition *transition = [CATransition new];
        transition.type = kCATransitionPush;
        transition.subtype = show ? kCATransitionFromTop : kCATransitionFromBottom;
        transition.duration = 0.4;
        transition.delegate = self;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [transition setValue:[NSNumber numberWithBool:show] forKey:@"PhotoViewShow"];
        [bgView.layer addAnimation:transition forKey:@"Transition"];
        
    } else {
        self.hidden = !show;
    }
    
    overlayView.hidden = !show;
    [bgView moveTo:CGPointMake(0, show ? self.frame.size.height - bgView.frame.size.height : self.frame.size.height)];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    BOOL show = [[theAnimation valueForKey:@"PhotoViewShow"] intValue];
    if (!show) self.hidden = YES;
}

- (void)show:(BOOL)show animated:(BOOL)animated
{
    [self show:show withExitButton:NO replyPhoto:nil animated:animated];
}

- (void)show:(BOOL)show withExitButton:(BOOL)needExitButton animated:(BOOL)animated
{
    [self show:show withExitButton:needExitButton replyPhoto:nil animated:animated];
}

- (void)show:(BOOL)show replyToPhoto:(VKPhoto *)photo animated:(BOOL)animated
{
    [self show:show withExitButton:NO replyPhoto:photo animated:animated];
}

#pragma mark - reset CameraRoll Button


- (void)resetCameraRollButtonWithReply:(BOOL)reply
{
    CGRect rect = libraryPlaceholder.frame;
    
    if (reply) {
        cameraRollButton.titleEdgeInsets = UIEdgeInsetsMake(10, -17, 0, 0);
        cameraRollButton.imageEdgeInsets = UIEdgeInsetsMake(14, 285, 0, 0);
        cameraRollButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [cameraRollButton setTitle:@"Choose your photo reply" forState:UIControlStateNormal];
        
        rect.origin.y = cameraRollButton.frame.origin.y + cameraRollButton.frame.size.height - rect.size.height;
        libraryPlaceholder.frame = rect;
    } else {
        cameraRollButton.titleEdgeInsets = UIEdgeInsetsMake(80, -17, 0, 0);
        cameraRollButton.imageEdgeInsets = UIEdgeInsetsMake(78, 285, 0, 0);
        cameraRollButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cameraRollButton setTitle:@"Camera Roll" forState:UIControlStateNormal];
        
        rect.origin.y = cameraRollButton.frame.origin.y;
        libraryPlaceholder.frame = rect;
    }
}

#pragma mark - actions

- (IBAction)cameraRoll
{
    [delegate choosePhotoViewDidChooseCameraRoll:self];
}

- (IBAction)takePhoto
{
    [delegate choosePhotoViewDidChooseCamera:self];
}

- (IBAction)cancel
{
    [delegate choosePhotoViewDidCancel:self];
}

- (IBAction)exit
{
    [delegate choosePhotoViewDidExit:self];
}

#pragma mark - LibraryPhotosViewDelegate

- (void)libraryPhotoView:(LibraryPhotosView *)view didTapOnImage:(UIImage *)image
{
    [delegate choosePhotoView:self didChooseImage:image];
}

@end
