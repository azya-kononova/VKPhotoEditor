//
//  ChoosePhotoView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/29/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ChoosePhotoView.h"
#import "UIColor+VKPhotoEditor.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Helpers.h"
#import "CALayer+Animations.h"
#import "ALAsset+UIImage.h"

@implementation ChoosePhotoView {
    ALAssetsLibrary *library;
    NSMutableArray *assets;
}
@synthesize overlayView;
@synthesize bgView;
@synthesize takePhotoButton;
@synthesize cancelButton;
@synthesize thumbnailsView;
@synthesize noPhotoLabel;
@synthesize activityView;
@synthesize exitButton;
@synthesize delegate;

- (void)awakeFromNib
{
    bgView.backgroundColor = [UIColor defaultBgColor];
    
    library = [[ALAssetsLibrary alloc] init];
    
    takePhotoButton.bgImagecaps = CGSizeMake(20, 20);
    cancelButton.bgImagecaps = CGSizeMake(20, 20);
    takePhotoButton.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [self show:NO animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show:(BOOL)show withExitButton:(BOOL)needExitButton animated:(BOOL)animated
{
    exitButton.hidden = !needExitButton;
    
    if (show) [self loadAlbumImages];
    
    if (animated) {
        if (show) self.hidden = NO;
        [overlayView.layer fade];
        
        CATransition *transition = [CATransition new];
        transition.type = kCATransitionPush;
        transition.subtype = show ? kCATransitionFromTop : kCATransitionFromBottom;
        transition.duration = 0.4;
        transition.delegate = self;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [transition setValue:[NSNumber numberWithBool:show] forKey:@"PhotoViewShow"];
        [bgView.layer addAnimation:transition forKey:@"Transition"];
        
    } else {
        self.hidden = !show;
    }
    
    overlayView.hidden = !show;
    [bgView moveTo:CGPointMake(0, show ? self.frame.size.height - bgView.frame.size.height : self.frame.size.height)];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    BOOL show = [[theAnimation valueForKey:@"PhotoViewShow"] intValue];
    if (!show) self.hidden = YES;
}

- (void)show:(BOOL)show animated:(BOOL)animated
{
    [self show:show withExitButton:NO animated:animated];
}

#pragma mark - actions

- (IBAction)cameraRoll
{
    [delegate choosePhotoViewDidChooseCameraRoll:self];
}

- (IBAction)takePhoto
{
    [delegate choosePhotoViewDidChooseCamera:self];
}

- (IBAction)cancel
{
    [delegate choosePhotoViewDidCancel:self];
}

- (IBAction)exit
{
    [delegate choosePhotoViewDidExit:self];
}

- (void)clearThumbnailsImages
{
    if (assets) {
        [assets removeAllObjects];
        assets = nil;
        [thumbnailsView reloadData];
    }
}

- (void)loadAlbumImages
{
    [self clearThumbnailsImages];
    
    assets = [NSMutableArray array];
    [activityView startAnimating];
    
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
                
                noPhotoLabel.hidden = assets.count;
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Can not get images from Photo Library.");
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
    [delegate choosePhotoView:self didChooseImage:[[assets objectAtIndex:index] image]];
}

@end
