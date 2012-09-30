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

#import "UIView+NIB.h"
#import "UITableViewCell+NIB.h"

#define kVSPathsKey @"vsPaths"
#define kFSPathsKey @"fsPaths"

@interface TakePhotoController ()<XBFilteredCameraViewDelegate, ThumbnailsViewDataSource, ThumbnailsViewDelegate, TableViewPopoverDataSource, TableViewPopoverDelegate> {
    IBOutlet XBFilteredCameraView *cameraView;
    
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

@property (nonatomic, assign) NSUInteger filterIndex;
@property (nonatomic, copy) NSArray *filterPathArray;
@property (nonatomic, copy) NSArray *filterNameArray;

@end

@implementation TakePhotoController

@synthesize delegate;
@synthesize filterIndex = _filterIndex;
@synthesize filterPathArray = _filterPathArray;
@synthesize filterNameArray = _filterNameArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filters = Filters.filters;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
    
    flashPopover = [self loadPopoverWithOriginPoint:CGPointMake(44, 70)];
    blurPopover = [self loadPopoverWithOriginPoint:CGPointMake(235, 70)];
    
    [self loadPopoversData];
    
    cameraView.updateSecondsPerFrame = YES;

    [self setupFilterPaths];
    self.filterIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [cameraView startCapturing];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [cameraView stopCapturing];
}

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
    
    NSDictionary *paths = [self.filterPathArray objectAtIndex:self.filterIndex];
    NSArray *fsPaths = [paths objectForKey:kFSPathsKey];
    NSArray *vsPaths = [paths objectForKey:kVSPathsKey];
    NSError *error = nil;
    if (vsPaths != nil) {
        [cameraView setFilterFragmentShaderPaths:fsPaths vertexShaderPaths:vsPaths error:&error];
    }
    else {
        [cameraView setFilterFragmentShaderPaths:fsPaths error:&error];
    }
    
    if (error != nil) {
        NSLog(@"Error setting shader: %@", [error localizedDescription]);
    }
    
        // Perform a few filter-specific initialization steps, like setting additional textures and uniforms
    NSString *filterName = [self.filterNameArray objectAtIndex:self.filterIndex];
    if ([filterName isEqualToString:@"Overlay"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"LucasCorrea" ofType:@"png"];
        XBTexture *texture = [[XBTexture alloc] initWithContentsOfFile:path options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
        GLKProgram *program = [cameraView.programs objectAtIndex:0];
        [program bindSamplerNamed:@"s_overlay" toXBTexture:texture unit:1];
        [program setValue:(void *)&GLKMatrix2Identity forUniformNamed:@"u_rawTexCoordTransform"];
    }
    else if ([filterName isEqualToString:@"Sharpen"]) {
        GLKMatrix2 rawTexCoordTransform = (GLKMatrix2){cameraView.cameraPosition == XBCameraPositionBack? 1: -1, 0, 0, -0.976};
        GLKProgram *program = [cameraView.programs objectAtIndex:1];
        [program bindSamplerNamed:@"s_mainTexture" toTexture:cameraView.mainTexture unit:1];
        [program setValue:(void *)&rawTexCoordTransform forUniformNamed:@"u_rawTexCoordTransform"];
    }
}

- (void)setupFilterPaths
{
    NSString *defaultVSPath = [[NSBundle mainBundle] pathForResource:@"DefaultVertexShader" ofType:@"glsl"];
    NSString *defaultFSPath = [[NSBundle mainBundle] pathForResource:@"DefaultFragmentShader" ofType:@"glsl"];
    NSString *overlayFSPath = [[NSBundle mainBundle] pathForResource:@"OverlayFragmentShader" ofType:@"glsl"];
    NSString *overlayVSPath = [[NSBundle mainBundle] pathForResource:@"OverlayVertexShader" ofType:@"glsl"];
    NSString *luminancePath = [[NSBundle mainBundle] pathForResource:@"LuminanceFragmentShader" ofType:@"glsl"];
    NSString *blurFSPath = [[NSBundle mainBundle] pathForResource:@"BlurFragmentShader" ofType:@"glsl"];
    NSString *sharpFSPath = [[NSBundle mainBundle] pathForResource:@"UnsharpMaskFragmentShader" ofType:@"glsl"];
    NSString *hBlurVSPath = [[NSBundle mainBundle] pathForResource:@"HBlurVertexShader" ofType:@"glsl"];
    NSString *vBlurVSPath = [[NSBundle mainBundle] pathForResource:@"VBlurVertexShader" ofType:@"glsl"];
    NSString *discretizePath = [[NSBundle mainBundle] pathForResource:@"DiscretizeShader" ofType:@"glsl"];
    NSString *pixelatePath = [[NSBundle mainBundle] pathForResource:@"PixelateShader" ofType:@"glsl"];
    NSString *suckPath = [[NSBundle mainBundle] pathForResource:@"SuckShader" ofType:@"glsl"];
    
        // Setup a combination of these filters
    self.filterPathArray = [[NSArray alloc] initWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:defaultFSPath], kFSPathsKey, nil], // No Filter
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:overlayFSPath], kFSPathsKey, [NSArray arrayWithObject:overlayVSPath], kVSPathsKey, nil], // Overlay
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:suckPath], kFSPathsKey, nil], // Spread
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:pixelatePath], kFSPathsKey, nil], // Pixelate
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:discretizePath], kFSPathsKey, nil], // Discretize
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:luminancePath], kFSPathsKey, nil], // Luminance
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:blurFSPath], kFSPathsKey, [NSArray arrayWithObject:hBlurVSPath], kVSPathsKey,nil], // Horizontal Blur
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:blurFSPath], kFSPathsKey, [NSArray arrayWithObject:vBlurVSPath], kVSPathsKey,nil], // Vertical Blur
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:blurFSPath, blurFSPath, nil], kFSPathsKey, [NSArray arrayWithObjects:vBlurVSPath, hBlurVSPath, nil], kVSPathsKey, nil], // Blur
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:luminancePath, blurFSPath, blurFSPath, nil], kFSPathsKey, [NSArray arrayWithObjects:defaultVSPath, vBlurVSPath, hBlurVSPath, nil], kVSPathsKey, nil], // Blur B&W
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:blurFSPath, sharpFSPath, nil], kFSPathsKey, [NSArray arrayWithObjects:vBlurVSPath, hBlurVSPath, nil], kVSPathsKey, nil], // Sharpen
                            [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:blurFSPath, blurFSPath, discretizePath, nil], kFSPathsKey, [NSArray arrayWithObjects:vBlurVSPath, hBlurVSPath, defaultVSPath, nil], kVSPathsKey, nil], nil]; // Discrete Blur
    
    self.filterNameArray = [[NSArray alloc] initWithObjects:@"No Filter", @"Overlay", @"Spread", @"Pixelate", @"Discretize", @"Luminance", @"Horizontal Blur", @"Vertical Blur", @"Blur", @"Blur B&W", @"Sharpen", @"Discrete Blur", nil];
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
        cameraView.flashMode = index;
    }
    [view show:NO];
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [delegate takePhotoController:self didFinishWithImage:nil];
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
    cameraView.cameraPosition = cameraView.cameraPosition == XBCameraPositionBack ? XBCameraPositionFront : XBCameraPositionBack;
}

@end
