//
//  CameraOverlayView.m
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CameraOverlayView.h"
#import "ThumbnailsView.h"
#import "Filters.h"

@interface CameraOverlayView () <ThumbnailsViewDataSource, ThumbnailsViewDelegate>
@end

@implementation CameraOverlayView {
    IBOutlet UILabel *flashLabel;
    IBOutlet ThumbnailsView *filtersView;
    
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *photoBtn;
    IBOutlet UIButton *filterBtn;
    
    NSArray *filters;
    NSArray *movingButtons;
}

@synthesize picker;

- (void)awakeFromNib
{
    filters = Filters.filters;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
}


#pragma mark ThumbnailView datasourse

- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view
{
    return filters.count;
}
- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    return [filters objectAtIndex:index];
}
- (CGFloat)thumbnailsView:(ThumbnailsView*)view thumbnailWidthForHeight:(CGFloat)height
{
    return height;
}


#pragma mark ThumbnailView delegate

- (void)thumbnailsView:(ThumbnailsView*)view didScrollToItemWithIndex:(NSUInteger)index
{
    
}
- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index
{
    
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [picker takePicture];
}

- (IBAction)cancel:(id)sender
{
    [picker.delegate imagePickerControllerDidCancel:picker];
}

- (IBAction)filters:(id)sender
{
    filtersView.hidden = !filtersView.hidden;
    
    [filtersView reloadData];
    NSInteger direction = filtersView.hidden ? -1 : 1;
    
    [UIView animateWithDuration:0.3 animations:^{
        for (UIButton *btn in movingButtons) {
            CGRect frame = btn.frame;
            frame.origin.y += direction * 15;
            btn.frame = frame;
        }
    }];
}

- (IBAction)flash:(id)sender
{
    
}

- (IBAction)blur:(id)sender
{
    
}

- (IBAction)rotateCamera:(id)sender
{
    picker.cameraDevice = picker.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
}

@end
