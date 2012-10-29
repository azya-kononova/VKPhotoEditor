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
#import "CALayer+Animations.h"
#import "UIView+Helpers.h"
#import "FlexibleTextField.h"
#import "UIButton+StateImage.h"
#import "UIViewController+Transitions.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "PhotosListController.h"

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
    BOOL isPostPhotoMode;
    VKRequestExecutor *exec;
    
    UIImage *savedImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    postView.backgroundColor = [UIColor defaultBgColor];
    [self.view addSubview:postView];
    [postView moveTo:CGPointMake(0,self.view.frame.size.height)];
    
    library = [[ALAssetsLibrary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAlbumImages) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    takePhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    postPhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    loginInputField.verticalPadding = 10;
    loginInputField.horizontalPadding = 95;
    
    takePhotoBtn.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [appNameLabel setFont:[UIFont fontWithName:@"Lobster 1.4" size:36.0]];
    
    [self loadAlbumImages];
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
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Can not get images from Photo Library.");
    }];
}

<<<<<<< HEAD
=======
#pragma mark - Photos

- (void)editPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex blurFilter:(id)blurFilter
{
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:image filterIndex:filterIndex blurFilter:blurFilter];
    photoEditController.delegate = self;
    
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

>>>>>>> take blur filter after take photo
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
    exec = [[VKConnectionService shared] login:loginInputField.text];
    exec.delegate = self;
    [exec start];
}

- (void)showPostViewHeader:(BOOL)show
{
    [UIView animateWithDuration:0.4 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
        [postView moveTo:CGPointMake(0, self.view.frame.size.height - 45)];
    } completion:nil];
}

- (void)showPost:(BOOL)show
{
    if (!show) [loginInputField resignFirstResponder];
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
    
    ALAssetRepresentation *representation = [[assets objectAtIndex:index] defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:1.0 orientation:representation.orientation];

    [self cropPhoto:image];
}


<<<<<<< HEAD
=======
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

- (void)croppingViewController:(CroppingViewController *)controller didFinishWithImage:(UIImage *)image filterIndex:(NSInteger)index blurFilter:(id)blurFilter
{
    [self dismissModalViewControllerAnimated:NO];
    [self editPhoto:image filterIndex:index blurFilter:blurFilter];
}


>>>>>>> take blur filter after take photo
#pragma  mark - PhotoEditControllerDelegate


- (void)photoEditController:(PhotoEditController *)controller didEdit:(UIImage *)image
{
    [self.navigationController popViewControllerAnimated:YES];
    [self clearThumbnailsImages];
    [activityIndicator startAnimating];
    savedImage = image;
    postImageView.image = savedImage;
    [self showPostViewHeader:YES];
    
//    UIImageWriteToSavedPhotosAlbum( image , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

<<<<<<< HEAD
=======
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

>>>>>>> take blur filter after take photo
#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    PhotosListController *ctrl = [[PhotosListController alloc] initWithImageToUpload:savedImage];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    
}

@end
