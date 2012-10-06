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
    IBOutlet UILabel *choosePhotoLabel;
    IBOutlet UILabel *noPhotoLabel;
    IBOutlet UILabel *appNameLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    library = [[ALAssetsLibrary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAlbumImages) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    takePhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    cameraRollBtn.bgImagecaps = CGSizeMake(20, 20);
    
    gallery.highlight = NO;
    
    takePhotoBtn.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [appNameLabel setFont:[UIFont fontWithName:@"Lobster 1.4" size:36.0]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadAlbumImages
{
    if (assets) {
        [assets removeAllObjects];
        assets = nil;
        [gallery reloadData];
    }
    
    assets = [NSMutableArray array];
    
    [activityIndicator startAnimating];
    
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
                
                noPhotoLabel.hidden = assets.count;
                choosePhotoLabel.hidden = !noPhotoLabel.hidden;
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Can not get images from Photo Library.");
    }];
}

#pragma mark - Photos

- (void)editPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex
{
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:image filterIndex:filterIndex];
    photoEditController.delegate = self;
    
    [self.navigationController pushViewController:photoEditController animated:NO];
}

- (void)cropPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex
{
    CroppingViewController *controller = [[CroppingViewController alloc] initWithImage:image filterIndex:filterIndex];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:NO];
}

- (void)cropPhoto:(UIImage *)image
{
    [self cropPhoto:image filterIndex:0];
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

- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image filterIndex:(NSInteger)index
{
    [self dismissModalViewControllerAnimated:NO];
    [self editPhoto:image filterIndex:index];
}


#pragma  mark - PhotoEditControllerDelegate

- (void)photoEditControllerDidCancel:(PhotoEditController *)controller
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self loadAlbumImages];
}

- (void)photoEditControllerDidRetake:(PhotoEditController *)_controller
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self takePhoto];
}

- (void)photoEditControllerDidSave:(PhotoEditController *)controller
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self loadAlbumImages];
}

#pragma mark - TakePhotoControllerDelegate

- (void)takePhotoControllerDidCancel:(TakePhotoController *)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)takePhotoController:(TakePhotoController *)controller didFinishWithBasicImage:(UIImage *)basic filterIndex:(NSInteger)index
{
    [self dismissModalViewControllerAnimated:NO];
    
    isPhoto = YES;
    [self cropPhoto:basic filterIndex:index];
}

@end
