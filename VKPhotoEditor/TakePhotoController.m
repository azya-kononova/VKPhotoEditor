    //
    //  TakePhotoController.m
    //  VKPhotoEditor
    //
    //  Created by asya on 9/30/12.
    //  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
    //

#import "TakePhotoController.h"
#import "ThumbnailsView.h"
#import "TableViewPopover.h"
#import "TablePopoverCell.h"
#import "Filters.h"
#import "ImageFilter.h"
#import "FlashMode.h"
#import "BlurMode.h"
#import "BlurFilterParams.h"
#import "FiltersManager.h"
#import "BlurView.h"

#import "UIView+NIB.h"
#import "UITableViewCell+NIB.h"

#import "GPUImageView.h"
#import "GPUImageStillCamera.h"
#import "GPUImageGaussianSelectiveBlurFilter.h"
#import "GPUImageTiltShiftFilter.h"


@interface TakePhotoController ()<ThumbnailsViewDataSource, ThumbnailsViewDelegate, TableViewPopoverDataSource, TableViewPopoverDelegate, UIGestureRecognizerDelegate, BlurViewDelegate> {
    IBOutlet GPUImageView *cameraView;
    IBOutlet UIImageView *blurImageView;
    IBOutlet UIImageView *flashImageView;
    IBOutlet UILabel *flashLabel;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *photoBtn;
    IBOutlet UIButton *filterBtn;
    IBOutlet ThumbnailsView *filtersView;
    IBOutlet UIView *focusAreaView;
    IBOutlet UIView *focusView;
    
    TableViewPopover *flashPopover;
    BlurView *blurView;
    
    NSArray *filters;
    NSArray *movingButtons;
    
    NSArray *flashModes;
    GPUImageStillCamera *stillCamera;
    FiltersManager *manager;
}

@end

@implementation TakePhotoController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filtersView.thumbConrnerRadius = 7.0;
    
    filters = Filters.filters;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    GPUImageOutput<GPUImageInput> *basicFilter = [GPUImageEmptyFilter new];
    [basicFilter prepareForImageCapture];
    [basicFilter addTarget:cameraView];
    
    [stillCamera addTarget:basicFilter];
    
    flashPopover = [self loadPopoverWithOriginPoint:CGPointMake(44, 70)];
    flashModes = [self availabelFlashMode];
    
    if (flashModes.count) {
        [self setCameraFlashMode:[flashModes objectAtIndex:1]];
    }
    
    blurView = [[BlurView alloc] initWithCenter:CGPointMake(235, 70) margin:CGRectGetMaxY(flashLabel.frame)];
    blurView.delegate = self;
    [self.view addSubview:blurView];
    [self.view addGestureRecognizer:blurView.pinch];
    
    filtersView.highlight = YES;
    
    manager = FiltersManagerMake(basicFilter, stillCamera, cameraView);
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraFocus:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [stillCamera startCameraCapture];
    photoBtn.enabled = YES;
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

- (void)setCameraFlashMode:(FlashMode *)mode
{
    flashImageView.image = mode.image;
    flashLabel.text = mode.name;
    
    [stillCamera.inputCamera lockForConfiguration:nil];
    [stillCamera.inputCamera setFlashMode:mode.mode];
    [stillCamera.inputCamera unlockForConfiguration];
}

- (void)showFocusViewInPoint:(CGPoint)point
{
    focusView.center = point;
    focusView.hidden = NO;
    [focusView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.8];
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
    [manager setFilterWithIndex:index];
}


#pragma mark - TableViewPopover DataSourse

- (UITableViewCell*)tableViewPopover:(TableViewPopover*)view cellForRowAtIndex:(NSInteger)index inTableView:(UITableView*)tableView
{
    TablePopoverCell *cell = [TablePopoverCell dequeOrCreateInTable:tableView];
    cell.imageView.image = [[flashModes objectAtIndex:index] image];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableViewPopoverRowsNumber:(TableViewPopover *)view
{
    return flashModes.count;
}

#pragma mark - TableViewPopover Delegate

- (void)tableViewPopover:(TableViewPopover *)view didSelectRowAtIndex:(NSInteger)index
{
    [self setCameraFlashMode:[flashModes objectAtIndex:index]];
    [view show:NO];
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [(UIButton *)sender setEnabled:NO];
    		
    __block TakePhotoController *blockSelf = self;
    
    //TODO: calculate size depens on screen size and selected camera
    [manager.basicFilter forceProcessingAtSize:CGSizeMake(1024, 1024*4/3)];
    [stillCamera capturePhotoAsImageProcessedUpToFilter:manager.basicFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        [delegate takePhotoController:blockSelf didFinishWithBasicImage:processedImage filterIndex:manager.filterIndex blurFilter:manager.blurFilter];
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
    [blurView show:NO];
    if (stillCamera.inputCamera.flashAvailable) {
        [flashPopover show:!flashPopover.isShown];
        [flashPopover reloadData];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@" Your device does not support flash." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)blur:(id)sender
{
    [blurView reloadData];
    [blurView show:!blurView.isShown];
    [flashPopover show:NO];
}

- (IBAction)rotateCamera:(id)sender
{
    [stillCamera rotateCamera];
}

- (void)cameraFocus:(UITapGestureRecognizer *)recognizer
{
    CGPoint touch = [recognizer locationInView:self.view];
    
    if ([stillCamera.inputCamera isFocusPointOfInterestSupported]) {
        [self showFocusViewInPoint:touch];
        
        [stillCamera.inputCamera lockForConfiguration:nil];
        [stillCamera.inputCamera setFocusPointOfInterest:touch];
        [stillCamera.inputCamera unlockForConfiguration];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.view];
    
    BOOL onFlashPopover = flashPopover.isShown && CGRectContainsPoint(flashPopover.frame, point);
    BOOL onBlurView = blurView.isShown && CGRectContainsPoint(blurView.frame, point);
    BOOL onCamera = CGRectContainsPoint(focusAreaView.frame, point);
    
    return onCamera && !(onFlashPopover || onBlurView);
}

#pragma mark - BlurViewDelegate

- (void)blurView:(BlurView *)view didFinishWithBlurMode:(BlurMode *)mode
{
    blurImageView.image = mode.iconImage;
    [manager setBlurFilterWithMode:mode];
}

- (void)blurView:(BlurView *)view didChangeBlurRadius:(CGFloat)radius
{
    [manager setBlurFilterRadius:radius];
}

@end
