//
//  StartViewController.m
//  VKPhotoEditor
//
//  Created by asya on 9/21/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "StartViewController.h"
#import "FlexibleButton.h"
#import "UIColor+VKPhotoEditor.h"
#import "CroppingViewController.h"
#import "PhotoEditController.h"
#import "TakePhotoController.h"
#import "CALayer+Animations.h"
#import "UIView+Helpers.h"
#import "FlexibleTextField.h"
#import "UIButton+StateImage.h"
#import "UIViewController+Transitions.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "PhotosListController.h"
#import "Settings.h"
#import "UINavigationController+Transistions.h"
#import "ErrorMessage.h"
#import "LibraryPhotosView.h"


@interface StartViewController ()<LibraryPhotosViewDelegate, VKRequestExecutorDelegate>
- (IBAction)takePhoto:(id)sender;
- (IBAction)cameraRoll:(id)sender;
@end


@implementation StartViewController {
    BOOL isPhoto;
    IBOutlet FlexibleButton *takePhotoBtn;
    IBOutlet FlexibleButton *postPhotoBtn;
    IBOutlet UILabel *appNameLabel;
    IBOutlet UIView *postView;
    IBOutlet FlexibleTextField *loginInputField;
    IBOutlet UIButton *postHeaderBtn;
    IBOutlet UIImageView *postImageView;
    IBOutlet UIActivityIndicatorView *loginActivity;
    IBOutlet UIView *libraryPlaceholder;
    
    LibraryPhotosView *libraryPhotosView;
    
    BOOL isPostPhotoMode;
    VKRequestExecutor *exec;
    
    IBOutlet UILabel* errorLabel;
    
    ImageToUpload *imageToUpload;
    
    BOOL isPostViewFrameUpdated;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    libraryPhotosView = [LibraryPhotosView loadFromNIB];
    libraryPhotosView.delegate = self;
    [libraryPlaceholder addSubview:libraryPhotosView];
    
    postView.backgroundColor = [UIColor defaultBgColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAlbumImages) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    takePhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    postPhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    loginInputField.verticalPadding = 10;
    loginInputField.horizontalPadding = 95;
    
    takePhotoBtn.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [appNameLabel setFont:[UIFont fontWithName:@"Lobster 1.4" size:36.0]];
    
    [self loadAlbumImages];
    
    postImageView.layer.cornerRadius = 5.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isPostViewFrameUpdated && ![Settings current].firstLaunch) [self showPostViewHeaderLogin:YES];
    isPostViewFrameUpdated = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [self takePhoto];
}

- (IBAction)cameraRoll:(id)sender
{
    [self choosePhoto];
}

- (IBAction)showPost
{
    [self showPost:!isPostPhotoMode];
}

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)postPhoto
{
    if (exec) return;
    [loginActivity startAnimating];
    [loginInputField resignFirstResponder];
    loginInputField.userInteractionEnabled = postPhotoBtn.userInteractionEnabled = NO;
    errorLabel.text = nil;
    exec = [[VKConnectionService shared] login:loginInputField.text];
    exec.delegate = self;
    [exec start];
}

- (void)showPostViewHeaderLogin:(BOOL)login
{
    [postHeaderBtn setTitle:login ? @"Login in Pictograph" : @"Post to Pictograph" forState:UIControlStateNormal];
    [postPhotoBtn setTitle:login ? @"Login" : @"Post photo" forState:UIControlStateNormal];
    if (login) imageToUpload = nil;
    postImageView.image = imageToUpload.image;
    
    [UIView animateWithDuration:0.4 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
        [postView moveTo:CGPointMake(0, self.view.frame.size.height - 45)];
    } completion:nil];
}

- (void)showPost:(BOOL)show
{
    if (!show) {
        [loginInputField resignFirstResponder];
        [exec stop];
        [self loginDidFinish];
    }
    [postHeaderBtn setDefaultImage:[UIImage imageNamed: show ? @"Cancel.png" : @"DownArrow.png" ]
                       higthligted:[UIImage imageNamed:show ?  @"Cancel_Active.png" : @"DownArrow_Active.png"]];
    [UIView animateWithDuration:1 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
        [postView moveTo:CGPointMake(0, show ? 0 : self.view.frame.size.height - 45)];
    } completion:^(BOOL finished) {
        isPostPhotoMode = show;
        if (show) [loginInputField becomeFirstResponder];
    }];
}

- (void)loadAlbumImages
{
    [libraryPhotosView reloadData];
}

#pragma mark - LibraryPhotosViewDelegate

- (void)libraryPhotoView:(LibraryPhotosView *)view didTapOnImage:(UIImage *)image
{
    isPhoto = NO;
    [self cropPhoto:image];
}


#pragma  mark - PhotoEditControllerDelegate


- (void)photoEditController:(PhotoEditController *)controller didFinishWithImage:(ImageToUpload*)image
{
    [self.navigationController popViewControllerAnimated:YES];
    [libraryPhotosView clear];
    libraryPhotosView.isLoading = YES;
    imageToUpload = image;
    postImageView.image = imageToUpload.image;
    [self showPostViewHeaderLogin:NO];
    
    [super photoEditController:controller didFinishWithImage:image];
}

#pragma mark - VKRequestExecutorDelegate

- (void)loginDidFinish
{
    [loginActivity stopAnimating];
    loginInputField.userInteractionEnabled = postPhotoBtn.userInteractionEnabled = YES;
    exec = nil;
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    PhotosListController *ctrl = [[PhotosListController alloc] initWithImageToUpload:imageToUpload];
    [self.navigationController pushViewController:ctrl transition:UIViewAnimationTransitionFlipFromRight];
    [self showPost:NO];
    [self showPostViewHeaderLogin:YES];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    errorLabel.text = [ErrorMessage loginMessageWithError:error loginData:loginInputField.text];
    [self loginDidFinish];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    
}

@end