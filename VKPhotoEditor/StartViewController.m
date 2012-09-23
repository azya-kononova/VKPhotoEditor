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


@interface StartViewController ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate>
- (IBAction)takePhoto:(id)sender;
- (IBAction)cameraRoll:(id)sender;
@end


@implementation StartViewController {
    NSMutableArray *assets;
    
    IBOutlet ThumbnailsView *gallery;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet FlexibleButton *takePhotoBtn;
    IBOutlet FlexibleButton *cameraRollBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    takePhotoBtn.bgImagecaps = CGSizeMake(20, 20);
    cameraRollBtn.bgImagecaps = CGSizeMake(20, 20);
    
    [self loadAlbumImages];
}

- (void)loadAlbumImages
{
    [activityIndicator startAnimating];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
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


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    
}

- (IBAction)cameraRoll:(id)sender
{        
    
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
    NSLog(@"Tap on image num.%d", index);
}

@end
