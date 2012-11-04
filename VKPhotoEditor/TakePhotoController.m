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
#import "GPUImageView.h"
#import "GPUImageStillCamera.h"

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
    
    PrepareFilter prepareBlock;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
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
    
    blurView = [[BlurView alloc] initWithCenter:CGPointMake(265, 70) margin:CGRectGetMaxY(flashLabel.frame)];
    blurView.delegate = self;
    [self.view addSubview:blurView];
    [self.view addGestureRecognizer:blurView.pinch];
    
    filtersView.highlight = YES;
    
    prepareBlock = ^(GPUImageOutput<GPUImageInput> *filter) {
        [filter prepareForImageCapture];
    };
    
    manager = FiltersManagerMake(basicFilter, stillCamera, cameraView);
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraFocus:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:stillCamera.captureSession];
    captureVideoPreviewLayer.frame = cameraView.frame;
    
    if ([captureVideoPreviewLayer isOrientationSupported]) {
        [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
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

- (void)forceProcessingAtScreenSize
{
    if (stillCamera.inputCamera.position == AVCaptureDevicePositionBack) {
        [manager.basicFilter forceProcessingAtSize:[(GPUImageFilter*)manager.basicFilter outputFrameSize]];
    }
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
    [manager setFilterWithIndex:index prepare:prepareBlock];
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
    
    [self forceProcessingAtScreenSize];
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
    CGPoint viewTouch = [recognizer locationInView:cameraView];
    CGPoint touch = [self convertToPointOfInterestFromViewCoordinates:viewTouch];
    [self showFocusViewInPoint:viewTouch];
    
    if ([stillCamera.inputCamera isFocusPointOfInterestSupported] && [stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [stillCamera.inputCamera lockForConfiguration:nil];
        [stillCamera.inputCamera setFocusPointOfInterest:touch];
        stillCamera.inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
        [stillCamera.inputCamera unlockForConfiguration];
    }
}

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = cameraView.frame.size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
            // Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[stillCamera videoCaptureConnection] inputPorts]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                            // If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                                // Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                            // If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                                // Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                        // Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
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

- (void)blurView:(BlurView *)view didFinishWithBlurMode:(BlurMode *)mode blurFilter:(id)filter
{
    blurImageView.image = mode.iconImage;
    [manager setBlurFilterWithMode:mode prepare:prepareBlock];
}

- (void)blurView:(BlurView *)view didChangeBlurScale:(CGFloat)scale
{
    [manager setBlurFilterScale:scale];
}

- (void)blurViewDidBeginBlurScaleEditing:(BlurView *)view
{
    [manager beginBlurScaleEditing];
}

- (void)blurViewDidFinishBlurScaleEditing:(BlurView *)view
{
    [manager finishBlurScaleEditing];
}

@end
