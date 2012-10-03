//
//  TakePhotoController.m
//  VKPhotoEditor
//
//  Created by asya on 9/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "TakePhotoController.h"
#import "XBFilteredCameraView.h"
#import "ThumbnailsView.h"
#import "TableViewPopover.h"
#import "TablePopoverCell.h"
#import "Filters.h"
#import "ImageFilter.h"

#import "UIView+NIB.h"
#import "UITableViewCell+NIB.h"

#import "GPUImageView.h"
#import "GPUImageStillCamera.h"
#import "GPUImageSketchFilter.h"
#import "GPUImageSepiaFilter.h"

#define kVSPathsKey @"vsPaths"
#define kFSPathsKey @"fsPaths"

@interface TakePhotoController ()<XBFilteredCameraViewDelegate, ThumbnailsViewDataSource, ThumbnailsViewDelegate, TableViewPopoverDataSource, TableViewPopoverDelegate> {
    IBOutlet GPUImageView *cameraView;
    
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
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter;
}

@property (nonatomic, assign) NSUInteger filterIndex;

@end

@implementation TakePhotoController

@synthesize delegate;
@synthesize filterIndex = _filterIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filters = Filters.filters;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
    
    flashPopover = [self loadPopoverWithOriginPoint:CGPointMake(44, 70)];
    blurPopover = [self loadPopoverWithOriginPoint:CGPointMake(235, 70)];
    
    [self loadPopoversData];
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    self.filterIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [stillCamera startCameraCapture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [stillCamera stopCameraCapture];
}


#pragma mark - Internals

- (TableViewPopover *)loadPopoverWithOriginPoint:(CGPoint)point
{
    TableViewPopover *popover = [TableViewPopover loadFromNIB];
    popover.delegate = self;
    popover.dataSource = self;
    [self.view addSubview:popover];
    popover.originPoint = point;
    popover.margin = CGRectGetMaxY(flashLabel.frame);
    
    return popover;
}

- (void)loadPopoversData
{
    flashLableNames = [NSArray arrayWithObjects:@"Off", @"On", @"Auto", nil];
    flashImageNames = [NSArray arrayWithObjects:@"Camera_Flash.png", @"Camera_Flash.png", @"Camera_Flash.png", nil];
    blurImageNames = [NSArray arrayWithObjects:@"Camera_Blur.png", @"Camera_Blur.png", @"Camera_Blur.png", nil];
}

- (void)setFilterIndex:(NSUInteger)filterIndex
{
    _filterIndex = filterIndex;
    ImageFilter *imageFilter = [filters objectAtIndex:filterIndex];
    
    [stillCamera removeAllTargets];
    [filter removeAllTargets];
    filter = [Filters GPUFilterWithName:imageFilter.name];
    [stillCamera addTarget:filter];
    [filter addTarget: cameraView];
    [filter prepareForImageCapture];
}


#pragma mark ThumbnailView datasourse

- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view
{
    return filters.count;
}

- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    ImageFilter *_filter = [filters objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:_filter.previewPath]];
}

- (CGFloat)thumbnailsView:(ThumbnailsView*)view thumbnailWidthForHeight:(CGFloat)height
{
    return height;
}


#pragma mark ThumbnailView delegate

- (void)thumbnailsView:(ThumbnailsView*)view didScrollToItemWithIndex:(NSUInteger)index { }

- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index
{
    self.filterIndex = index;
}


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
        [stillCamera.inputCamera setFlashMode:index];
    }
    [view show:NO];
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [stillCamera capturePhotoAsOriginalImageWithCompletionHandler:^(UIImage *processedImage, NSError *error) {
        [delegate takePhotoController:self didFinishWithBasicImage:processedImage filteredImage:processedImage filterIndex:1];
    }];
}

- (IBAction)cancel:(id)sender
{
    [delegate takePhotoControllerDidCancel:self];
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
    [stillCamera rotateCamera];
}

@end
