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
#import "TableViewPopover.h"
#import "UIView+NIB.h"
#import "UITableViewCell+NIB.h"
#import "TablePopoverCell.h"


@interface CameraOverlayView () <ThumbnailsViewDataSource, ThumbnailsViewDelegate, TableViewPopoverDataSource, TableViewPopoverDelegate>
@end

@implementation CameraOverlayView {
    IBOutlet UILabel *flashLabel;
    IBOutlet ThumbnailsView *filtersView;
    
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *photoBtn;
    IBOutlet UIButton *filterBtn;
    
    TableViewPopover *flashPopover;
    TableViewPopover *blurPopover;
    
    NSArray *filters;
    NSArray *movingButtons;
    
    NSArray *flashLableNames;
    NSArray *flashImageNames;
    NSArray *blurImageNames;
}

@synthesize picker;

- (void)awakeFromNib
{
    filters = Filters.filters;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
    
    flashPopover = [self loadPopoverWithOriginPoint:CGPointMake(44, 70)];
    blurPopover = [self loadPopoverWithOriginPoint:CGPointMake(235, 70)];
    
    [self loadPopoversData];
}

- (TableViewPopover *)loadPopoverWithOriginPoint:(CGPoint)point
{
    TableViewPopover *popover = [TableViewPopover loadFromNIB];
    popover.delegate = self;
    popover.dataSource = self;
    [self addSubview:popover];
    popover.originPoint = point;
    popover.margin = CGRectGetMaxY(flashLabel.frame);
    
    return popover;
}

- (void)loadPopoversData
{
    flashLableNames = [NSArray arrayWithObjects:@"Off", @"Auto", @"On", nil];
    flashImageNames = [NSArray arrayWithObjects:@"Camera_Flash.png", @"Camera_Flash.png", @"Camera_Flash.png", nil];
    blurImageNames = [NSArray arrayWithObjects:@"Camera_Blur.png", @"Camera_Blur.png", @"Camera_Blur.png", nil];
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

- (void)thumbnailsView:(ThumbnailsView*)view didScrollToItemWithIndex:(NSUInteger)index { }
- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index { }


#pragma mark - TableViewPopover DataSourse

- (UITableViewCell*)tableViewPopover:(TableViewPopover*)view cellForRowAtIndex:(NSInteger)index inTableView:(UITableView*)tableView
{
    TablePopoverCell *cell = [TablePopoverCell dequeOrCreateInTable:tableView];
    NSString *imageName = [view isEqual:flashPopover] ? [flashImageNames objectAtIndex:index] : [blurImageNames objectAtIndex:index];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableViewPopoverRowsNumber:(TableViewPopover *)view
{
    return [view isEqual:flashPopover] ? flashImageNames.count : blurImageNames.count;
}

#pragma mark - TableViewPopover Delegate

- (void)tableViewPopover:(TableViewPopover *)view didSelectRowAtIndex:(NSInteger)index
{
    if ([view isEqual:flashPopover]) {
        flashLabel.text = [flashLableNames objectAtIndex:index];
        picker.cameraFlashMode = index - 1;
    }
    [view show:NO];
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
    [flashPopover show:!flashPopover.isShown];
    [blurPopover show:NO];
    
    [flashPopover reloadData];
}

- (IBAction)blur:(id)sender
{
    [blurPopover show:!blurPopover.isShown];
    [flashPopover show:NO];
    
    [blurPopover reloadData];
}

- (IBAction)rotateCamera:(id)sender
{
    picker.cameraDevice = !picker.cameraDevice;
}

@end
