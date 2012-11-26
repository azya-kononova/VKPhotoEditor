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

- (void)awakeFromNib
{
    libraryPhotosView = [LibraryPhotosView loadFromNIB];
    libraryPhotosView.delegate = self;
    [libraryPlaceholder addSubview:libraryPhotosView];
    
    bgView.backgroundColor = [UIColor defaultBgColor];
    
    takePhotoButton.bgImagecaps = CGSizeMake(20, 20);
    cancelButton.bgImagecaps = CGSizeMake(20, 20);
    takePhotoButton.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [self show:NO animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show:(BOOL)show withExitButton:(BOOL)needExitButton animated:(BOOL)animated
{
    exitButton.hidden = !needExitButton;
    
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
    [self show:show withExitButton:NO animated:animated];
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
