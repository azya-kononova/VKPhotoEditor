//
//  PhotoManageBaseController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoManageBaseController.h"
#import "UIViewController+Transitions.h"

@interface PhotoManageBaseController ()
@end

@implementation PhotoManageBaseController
@synthesize isPhoto;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)editPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex
{
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:image filterIndex:filterIndex];
    photoEditController.delegate = self;
    
    [self.navigationController pushViewController:photoEditController animated:NO];
}

- (void)cropPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex userInfo:(NSDictionary *)userInfo
{
    CroppingViewController *controller = [[CroppingViewController alloc] initWithImage:image filterIndex:filterIndex userInfo:userInfo];
    controller.delegate = self;
    
    isPhoto ? [self presentModalViewController:controller animated:NO] : [self presentModalViewController:controller withPushDirection:kCATransitionFromRight];
}

- (void)cropPhoto:(UIImage *)image
{
    [self cropPhoto:image filterIndex:0 userInfo:nil];
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
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self cropPhoto:image];
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

- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image filterIndex:(NSInteger)index
{
    [self dismissModalViewControllerAnimated:NO];
    [self editPhoto:image filterIndex:index];
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

- (void)photoEditController:(PhotoEditController *)controller didEdit:(UIImage *)image
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

- (void)takePhotoController:(TakePhotoController *)controller didFinishWithBasicImage:(UIImage *)basic filterIndex:(NSInteger)index userInfo:(NSDictionary *)userInfo
{
    [self dismissModalViewControllerAnimated:NO];
    
    isPhoto = YES;
    [self cropPhoto:basic filterIndex:index userInfo:userInfo];
}
@end