//
//  PhotoManageBaseController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoManageBaseController.h"
#import "UIViewController+Transitions.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAsset+UIImage.h"

@interface PhotoManageBaseController ()
@end

@implementation PhotoManageBaseController
@synthesize isPhoto;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)editPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex blurFilter:(id)blurFilter
{
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:image filterIndex:filterIndex blurFilter:blurFilter];
    photoEditController.delegate = self;
    photoEditController.isPhoto = isPhoto;
    
    [self.navigationController pushViewController:photoEditController animated:NO];
}

- (void)cropPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex blurFilter:(id)blurFilter
{
    CroppingViewController *controller = [[CroppingViewController alloc] initWithImage:image filterIndex:filterIndex blurFilter:blurFilter];
    controller.delegate = self;
    
    isPhoto ? [self presentModalViewController:controller animated:NO] : [self presentModalViewController:controller withPushDirection:kCATransitionFromRight];
}

- (void)cropPhoto:(UIImage *)image
{
    [self cropPhoto:image filterIndex:0 blurFilter:nil];
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
    
    [self presentModalViewController:imagePicker withPushDirection:kCATransitionFromRight];
}

- (void)loadAlbumImages
{
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    isPhoto = picker.sourceType == UIImagePickerControllerSourceTypeCamera;
    [self dismissModalViewControllerAnimated:NO];
    
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        [self cropPhoto:[asset image]];
    } failureBlock:^(NSError *error) {
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
}


#pragma mark - CroppingViewControllerDelegate

- (void)croppingViewControllerDidCancel:(CroppingViewController *)controller
{
    isPhoto ? [self dismissModalViewControllerAnimated:NO] : [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
}

- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image filterIndex:(NSInteger)index blurFilter:(id)blurFilter
{
    [self dismissModalViewControllerAnimated:NO];
    [self editPhoto:image filterIndex:index blurFilter:blurFilter];
}


#pragma  mark - PhotoEditControllerDelegate

- (void)photoEditControllerDidCancel:(PhotoEditController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)photoEditControllerDidRetake:(PhotoEditController *)_controller
{
    [self.navigationController popViewControllerAnimated:NO];
    [self takePhoto];
}

- (void)photoEditControllerDidSelect:(PhotoEditController *)controller
{
    [self.navigationController popViewControllerAnimated:NO];
    [self choosePhoto];
}

- (void)photoEditController:(PhotoEditController *)controller didFinishWithImage:(ImageToUpload *)image
{
    // implement in subclass
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self loadAlbumImages];
}

#pragma mark - TakePhotoControllerDelegate

- (void)takePhotoControllerDidCancel:(TakePhotoController *)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)takePhotoController:(TakePhotoController *)controller didFinishWithBasicImage:(UIImage *)basic filterIndex:(NSInteger)index blurFilter:(id)blurFilter
{
    [self dismissModalViewControllerAnimated:NO];
    
    isPhoto = YES;
    [self cropPhoto:basic filterIndex:index blurFilter:blurFilter];
}

@end
