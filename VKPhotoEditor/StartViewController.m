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
#import "CameraOverlayView.h"
#import "UIView+NIB.h"
#import "UIColor+VKPhotoEditor.h"
#import "CroppingViewController.h"

@interface StartViewController ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CroppingViewControllerDelegate>
- (IBAction)takePhoto:(id)sender;
- (IBAction)cameraRoll:(id)sender;
@end


@implementation StartViewController {
    NSMutableArray *assets;
    ALAssetsLibrary *library;
    
    IBOutlet ThumbnailsView *gallery;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet FlexibleButton *takePhotoBtn;
    IBOutlet FlexibleButton *cameraRollBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    takePhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    cameraRollBtn.bgImagecaps = CGSizeMake(20, 20);
    
    gallery.highlight = NO;
    
    takePhotoBtn.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    library = [[ALAssetsLibrary alloc] init];
    [self loadAlbumImages];
}

- (void)loadAlbumImages
{
    [activityIndicator startAnimating];

    assets = [NSMutableArray array];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stopGroup) {
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
             if (asset) {
                 [assets addObject:asset];
             }
             
             if (*stop || index == NSNotFound) {
                 assets = [NSMutableArray arrayWithArray:[[assets reverseObjectEnumerator] allObjects]];
                 [gallery reloadData];
                 [activityIndicator stopAnimating];
             }
          }];
     } failureBlock:^(NSError *error) {
         NSLog(@"Can not get images from Photo Library.");
     }];
}

- (void)moveAndScaleImage:(UIImage *)image
{
    CroppingViewController *controller = [[CroppingViewController alloc] initWithImage:image];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:NO];
}

#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.showsCameraControls = NO;
    imagePicker.wantsFullScreenLayout = YES;
    imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imagePicker.allowsEditing = YES;
    
    CameraOverlayView *overlayView = [CameraOverlayView loadFromNIB];
    overlayView.picker = imagePicker;
    imagePicker.cameraOverlayView = overlayView;
    
    CGFloat cameraTransformX = 1.25;
    CGFloat cameraTransformY = 1.25;
    imagePicker.cameraViewTransform = CGAffineTransformScale(imagePicker.cameraViewTransform, cameraTransformX, cameraTransformY);
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)cameraRoll:(id)sender
{        
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:imagePicker animated:NO];
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
    [self moveAndScaleImage:[UIImage imageWithCGImage:[[[assets objectAtIndex:index] defaultRepresentation] fullResolutionImage]]];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:NO];
    
    [self moveAndScaleImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - CroppingViewControllerDelegate

- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image
{
    [self dismissModalViewControllerAnimated:NO];
    
    //TODO: open Edit Photo screen
}

- (void)croppingViewControllerDidCancel:(CroppingViewController *)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

@end
