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
#import "UIView+NIB.h"
#import "UIColor+VKPhotoEditor.h"
#import "CroppingViewController.h"
#import "PhotoEditController.h"
#import "TakePhotoController.h"

@interface StartViewController ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CroppingViewControllerDelegate, PhotoEditControllerDelegate, TakePhotoControllerDelegate>
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


#pragma mark - Photos

- (void)editPhoto:(UIImage *)image
{
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:image isPhoto:isPhoto];
    photoEditController.delegate = self;
    
    [self.navigationController pushViewController:photoEditController animated:NO];
}

- (void)cropPhoto:(UIImage *)image
{
    CroppingViewController *controller = [[CroppingViewController alloc] initWithImage:image];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:NO];
}

- (void)takePhoto
{
    TakePhotoController *controller = [TakePhotoController new];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:NO];
}

- (void)choosePhoto
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:imagePicker animated:NO];
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
    
    UIImage *image = [UIImage imageWithCGImage:[[[assets objectAtIndex:index] defaultRepresentation] fullResolutionImage]];
    [self cropPhoto:image];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    isPhoto = picker.sourceType == UIImagePickerControllerSourceTypeCamera;
    [self dismissModalViewControllerAnimated:NO];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self cropPhoto:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:NO];
}


#pragma mark - CroppingViewControllerDelegate

- (void)croppingViewControllerDidCancel:(CroppingViewController *)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image
{
    [self dismissModalViewControllerAnimated:NO];
    
    [self editPhoto:image];
}


#pragma  mark - PhotoEditControllerDelegate

- (void)photoEditControllerDidCancel:(PhotoEditController *)controller
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)photoEditControllerDidRetake:(PhotoEditController *)_controller
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self takePhoto];
}


#pragma mark - TakePhotoControllerDelegate

- (void)takePhotoControllerDidCancel:(TakePhotoController *)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)takePhotoController:(TakePhotoController *)controller didFinishWithBasicImage:(UIImage *)basic filteredImage:(UIImage *)filtered filterIndex:(NSInteger)index
{
    [self dismissModalViewControllerAnimated:NO];
    
    isPhoto = YES;
    [self cropPhoto:filtered];
}

@end
