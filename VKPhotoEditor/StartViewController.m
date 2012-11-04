//
//  StartViewController.m
//  VKPhotoEditor
//
//  Created by asya on 9/21/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "StartViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ThumbnailsView.h"
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
#import "ALAsset+UIImage.h"
#import "Settings.h"
#import "UINavigationController+Transistions.h"


@interface StartViewController ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate, VKRequestExecutorDelegate>
- (IBAction)takePhoto:(id)sender;
- (IBAction)cameraRoll:(id)sender;
@end


@implementation StartViewController {
    BOOL isPhoto;
    NSMutableArray *assets;
    ALAssetsLibrary *library;
    
    IBOutlet ThumbnailsView *gallery;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet FlexibleButton *takePhotoBtn;
    IBOutlet FlexibleButton *postPhotoBtn;
    IBOutlet UILabel *noPhotoLabel;
    IBOutlet UILabel *appNameLabel;
    IBOutlet UIView *postView;
    IBOutlet FlexibleTextField *loginInputField;
    IBOutlet UIButton *postHeaderBtn;
    IBOutlet UIImageView *postImageView;
    IBOutlet UIActivityIndicatorView *loginActivity;
    
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
    
    postView.backgroundColor = [UIColor defaultBgColor];
    
    library = [[ALAssetsLibrary alloc] init];
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

- (void)clearThumbnailsImages
{
    if (assets) {
        [assets removeAllObjects];
        assets = nil;
        [gallery reloadData];
    }
}

- (void)loadAlbumImages
{
    [self clearThumbnailsImages];
    
    assets = [NSMutableArray array];
    [activityIndicator startAnimating];
    gallery.userInteractionEnabled = NO;
    
    [self performSelector:@selector(loadAlbumImagesAfterDelay) withObject:nil afterDelay:0.5];
}

- (void)loadAlbumImagesAfterDelay
{
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stopGroup) {
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                [assets addObject:asset];
            }
            if (*stop || index == NSNotFound) {
                [assets sortUsingComparator:^NSComparisonResult(ALAsset *obj1, ALAsset *obj2) {
                    NSDate *first = [obj1 valueForProperty:ALAssetPropertyDate];
                    NSDate *second = [obj2 valueForProperty:ALAssetPropertyDate];
                    return -[first compare:second];
                }];
                
                [gallery reloadData];
                [activityIndicator stopAnimating];
                gallery.userInteractionEnabled = YES;
                
                noPhotoLabel.hidden = assets.count;
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Can not get images from Photo Library.");
    }];
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

#pragma mark - ThumbnailsViewDataSource

- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view
{
    return assets.count;
}

- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    UIImage *image = [UIImage imageWithCGImage:[[assets objectAtIndex:index] thumbnail]];
    
    return [[UIImageView alloc] initWithImage:image];
}

- (CGFloat)thumbnailsView:(ThumbnailsView*)view thumbnailWidthForHeight:(CGFloat)height
{
    return height;
}


#pragma mark - ThumbnailsViewDelegate

- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index
{
    isPhoto = NO;

    [self cropPhoto:[[assets objectAtIndex:index] image]];
}


#pragma  mark - PhotoEditControllerDelegate


- (void)photoEditController:(PhotoEditController *)controller didFinishWithImage:(ImageToUpload*)image
{
    [self.navigationController popViewControllerAnimated:YES];
    [self clearThumbnailsImages];
    [activityIndicator startAnimating];
    gallery.userInteractionEnabled = NO;
    imageToUpload = image;
    postImageView.image = imageToUpload.image;
    [self showPostViewHeaderLogin:NO];
    
    //    UIImageWriteToSavedPhotosAlbum( image , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
    errorLabel.text = error.localizedDescription;
    [self loginDidFinish];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    
}

@end