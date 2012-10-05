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
#import "FlashMode.h"
#import "BlurMode.h"

#import "UIView+NIB.h"
#import "UITableViewCell+NIB.h"

#import "GPUImageView.h"
#import "GPUImageStillCamera.h"
#import "GPUImageSketchFilter.h"
#import "GPUImageSepiaFilter.h"
#import "GPUImagePixellateFilter.h"

enum {
    CameraBlurModeOff = 0,
    CameraBlurModeLine = 1,
    CameraBlurModeRound = 2
};
typedef NSInteger CameraBlurMode;

@interface TakePhotoController ()<XBFilteredCameraViewDelegate, ThumbnailsViewDataSource, ThumbnailsViewDelegate, TableViewPopoverDataSource, TableViewPopoverDelegate> {
    IBOutlet GPUImageView *cameraView;
    IBOutlet UIImageView *blurImageView;
    IBOutlet UIImageView *flashImageView;
    IBOutlet UILabel *flashLabel;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *photoBtn;
    IBOutlet UIButton *filterBtn;
    IBOutlet ThumbnailsView *filtersView;
    
    TableViewPopover *flashPopover;
    TableViewPopover *blurPopover;
    
    NSArray *filters;
    NSArray *movingButtons;
    
    NSArray *flashModes;
    NSArray *blurModes;
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *basicFilter;
}

@property (nonatomic, assign) NSUInteger filterIndex;

@end

@implementation TakePhotoController

@synthesize delegate, filterIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filters = Filters.filters;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    basicFilter = [GPUImageEmptyFilter new];
    [basicFilter prepareForImageCapture];
    [basicFilter addTarget:cameraView];
    
    [stillCamera addTarget:basicFilter];
    
    flashPopover = [self loadPopoverWithOriginPoint:CGPointMake(44, 70)];
    flashModes = [self availabelFlashMode];
    
    blurPopover = [self loadPopoverWithOriginPoint:CGPointMake(235, 70)];
    blurModes = [self setBlurModes];
    
    if (flashModes.count) {
        [self setCameraFlashMode:[flashModes objectAtIndex:1]];
    }
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

- (void)setFilterIndex:(NSUInteger)_filterIndex
{
    filterIndex = _filterIndex;
    ImageFilter *imageFilter = [filters objectAtIndex:filterIndex];
    GPUImageOutput<GPUImageInput> *filter = [Filters GPUFilterWithName:imageFilter.name];
    
    [basicFilter replaceLastTargetWithTarget:filter];
    [filter addTarget: cameraView];
    [filter prepareForImageCapture];
}

- (NSArray *)availabelFlashMode
{
    NSMutableArray *modes = [NSMutableArray array];
    
    if ([stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeOn]) {
        [modes addObject:MakeFlashMode(AVCaptureFlashModeOn, @"On", @"flash_on.png")];
    }
    if ([stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
        [modes addObject:MakeFlashMode(AVCaptureFlashModeOff, @"Off", @"flash_off.png")];
    }
    if ([stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [modes addObject:MakeFlashMode(AVCaptureFlashModeAuto, @"Auto", @"flash_auto.png")];
    }
    
    return modes;
}

- (NSArray *)setBlurModes
{
    NSMutableArray *modes = [NSMutableArray array];
    
    [modes addObject:MakeBlurMode([GPUImageSepiaFilter new], @"blur_line.png", @"blur_line_icon.png")];
    [modes addObject:MakeBlurMode([GPUImagePixellateFilter new], @"blur_round.png", @"blur_round_icon.png")];
    [modes addObject:MakeBlurMode([GPUImageEmptyFilter new], @"blur_off.png", @"blur_off_icon.png")];
    
    return modes;
}
- (void)setCameraFlashMode:(FlashMode *)mode
{
    flashImageView.image = mode.image;
    flashLabel.text = mode.name;
    
    [stillCamera.inputCamera lockForConfiguration:nil];
    [stillCamera.inputCamera setFlashMode:mode.mode];
    [stillCamera.inputCamera unlockForConfiguration];
}

- (void)setCameraBlurMode:(BlurMode *)mode
{
    blurImageView.image = mode.iconImage;
    
    basicFilter = mode.filter;
    GPUImageOutput<GPUImageInput> *replacedTarget = [stillCamera.targets objectAtIndex:0];
    
    for (GPUImageOutput<GPUImageInput> *target in replacedTarget.targets) {
        [basicFilter addTarget:target];
    }
    [basicFilter prepareForImageCapture];
    
    [stillCamera replaceFirstTargetWithTarget:basicFilter];
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
    cell.imageView.image = [view isEqual:flashPopover] ? [[flashModes objectAtIndex:index] image] : [[blurModes objectAtIndex:index] image];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableViewPopoverRowsNumber:(TableViewPopover *)view
{
    return [view isEqual:flashPopover] ? flashModes.count : blurModes.count;
}

#pragma mark - TableViewPopover Delegate

- (void)tableViewPopover:(TableViewPopover *)view didSelectRowAtIndex:(NSInteger)index
{
    if ([view isEqual:flashPopover]) {
        [self setCameraFlashMode:[flashModes objectAtIndex:index]];
    } else if ([view isEqual:blurPopover]) {
        [self setCameraBlurMode:[blurModes objectAtIndex:index]];
    }
    
    [view show:NO];
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [stillCamera capturePhotoAsImageProcessedUpToFilter:basicFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        [delegate takePhotoController:self didFinishWithBasicImage:processedImage filterIndex:filterIndex];
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
    [blurPopover show:NO];
    if (stillCamera.inputCamera.flashAvailable) {
        [flashPopover show:!flashPopover.isShown];
        [flashPopover reloadData];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@" Your device does not support flash." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
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
