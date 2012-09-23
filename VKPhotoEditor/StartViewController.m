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

@interface StartViewController ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate>
- (IBAction)takePhoto:(id)sender;
- (IBAction)cameraRoll:(id)sender;
@end

@implementation StartViewController {
    NSMutableArray *albumImages;
    IBOutlet ThumbnailsView *gallery;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self loadAlbumImages];
}

- (void)loadAlbumImages
{
    [activityIndicator startAnimating];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    albumImages = [NSMutableArray array];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
             if (asset) {
                 UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                 [albumImages addObject:[[UIImageView alloc] initWithImage:image]];
             }
             
             if (*stop) {
                 albumImages = [NSMutableArray arrayWithArray:[[albumImages reverseObjectEnumerator] allObjects]];
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
    return albumImages.count;
}

- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    return [albumImages objectAtIndex:index];
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
