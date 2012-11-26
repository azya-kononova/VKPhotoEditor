//
//  LibraryPhotosView.m
//  VKPhotoEditor
//
//  Created by asya on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "LibraryPhotosView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAsset+UIImage.h"
#import "ThumbnailsView.h"

@interface LibraryPhotosView ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate>
@end

@implementation LibraryPhotosView {
    IBOutlet ThumbnailsView *thumbnailsView;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UILabel *noPhotoLabel;
    ALAssetsLibrary *library;
    NSMutableArray *assets;
}

@synthesize delegate;

- (void)awakeFromNib
{
    library = [[ALAssetsLibrary alloc] init];
}

- (void)clear
{
    if (assets) {
        [assets removeAllObjects];
        assets = nil;
        [thumbnailsView reloadData];
    }
}

- (void)reloadData
{
    [self clear];
    
    assets = [NSMutableArray array];
    [activityView startAnimating];
    
    thumbnailsView.userInteractionEnabled = NO;
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
                
                [thumbnailsView reloadData];
                [activityView stopAnimating];
                thumbnailsView.userInteractionEnabled = YES;
                
                noPhotoLabel.hidden = assets.count;
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Can not get images from Photo Library.");
    }];
}

- (BOOL)isLoading
{
    return activityView.isAnimating;
}

- (void)setIsLoading:(BOOL)loading
{
    if (loading) {
        [activityView startAnimating];
    } else {
        [activityView stopAnimating];
    }
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
    [delegate libraryPhotoView:self didTapOnImage:[[assets objectAtIndex:index] image]];
}

@end
