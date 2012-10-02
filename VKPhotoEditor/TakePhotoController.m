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
    NSArray *filtersName;
    NSArray *movingButtons;
    
    NSArray *flashLableNames;
    NSArray *flashImageNames;
    NSArray *blurImageNames;
    
    UIImage *initImage;
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
    filtersName = Filters.filtersName;
    movingButtons = [NSArray arrayWithObjects:cancelBtn, photoBtn, filterBtn, nil];
    
    flashPopover = [self loadPopoverWithOriginPoint:CGPointMake(44, 70)];
    blurPopover = [self loadPopoverWithOriginPoint:CGPointMake(235, 70)];
    
    [self loadPopoversData];
    
    cameraView.updateSecondsPerFrame = YES;

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


#pragma mark - Internals

- (GLKMatrix2)rawTextureCoordinatesTransform
{
    return (GLKMatrix2){cameraView.cameraPosition == XBCameraPositionBack? 1: -1, 0, 0, -0.976};
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
    
    ImageFilter *filter = [filters objectAtIndex:self.filterIndex];
    NSArray *fsPaths = filter.fragmentShaderPaths;
    NSArray *vsPaths = filter.vertexShaderPaths;
    NSError *error = nil;
    
    if (vsPaths) {
        [cameraView setFilterFragmentShaderPaths:fsPaths vertexShaderPaths:vsPaths error:&error];
    }
    else {
        [cameraView setFilterFragmentShaderPaths:fsPaths error:&error];
    }
    
    if (error != nil) {
        NSLog(@"Error setting shader: %@", [error localizedDescription]);
    }
    
        // Perform a few filter-specific initialization steps, like setting additional textures and uniforms
    NSString *filterName = [filtersName objectAtIndex:self.filterIndex];
    if ([filterName isEqualToString:@"Overlay"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"LucasCorrea" ofType:@"png"];
        XBTexture *texture = [[XBTexture alloc] initWithContentsOfFile:path options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
        GLKProgram *program = [cameraView.programs objectAtIndex:0];
        [program bindSamplerNamed:@"s_overlay" toXBTexture:texture unit:1];
        [program setValue:(void *)&GLKMatrix2Identity forUniformNamed:@"u_rawTexCoordTransform"];
    }
    else if ([filterName isEqualToString:@"Sharpen"]) {
        GLKMatrix2 rawTexCoordTransform = [self rawTextureCoordinatesTransform];
        GLKProgram *program = [cameraView.programs objectAtIndex:1];
        [program bindSamplerNamed:@"s_mainTexture" toTexture:cameraView.mainTexture unit:1];
        [program setValue:(void *)&rawTexCoordTransform forUniformNamed:@"u_rawTexCoordTransform"];
    }
}


#pragma mark ThumbnailView datasourse

- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view
{
    return filters.count;
}

- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    ImageFilter *filter = [filters objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:filter.previewPath]];
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
        cameraView.flashMode = index;
    }
    [view show:NO];
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    NSString *filterName = [filtersName objectAtIndex:self.filterIndex];
    if ([filterName isEqualToString:@"Overlay"]) {
        GLKMatrix2 rawTexCoordTransform = cameraView.rawTexCoordTransform;
        GLKProgram *program = [cameraView.programs objectAtIndex:0];
        [program setValue:(void *)&rawTexCoordTransform forUniformNamed:@"u_rawTexCoordTransform"];
    }
    else if ([filterName isEqualToString:@"Sharpen"]) {
        GLKMatrix2 rawTexCoordTransform = [self rawTextureCoordinatesTransform];
        GLKProgram *program = [cameraView.programs objectAtIndex:1];
        [program setValue:(void *)&rawTexCoordTransform forUniformNamed:@"u_rawTexCoordTransform"];
    }
    
    [cameraView takeAPhotoWithCompletion:^(UIImage *filteredImage) {
        [delegate takePhotoController:self didFinishWithBasicImage:nil filteredImage:filteredImage filterIndex:self.filterIndex];
        
            // Restore filter-specific state
        NSString *filterName = [filtersName objectAtIndex:self.filterIndex];
        if ([filterName isEqualToString:@"Overlay"]) {
            GLKProgram *program = [cameraView.programs objectAtIndex:0];
            [program setValue:(void *)&GLKMatrix2Identity forUniformNamed:@"u_rawTexCoordTransform"];
        }
        else if ([filterName isEqualToString:@"Sharpen"]) {
            GLKMatrix2 rawTexCoordTransform = [self rawTextureCoordinatesTransform];
            GLKProgram *program = [cameraView.programs objectAtIndex:1];
            [program setValue:(void *)&rawTexCoordTransform forUniformNamed:@"u_rawTexCoordTransform"];
        }
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
    cameraView.cameraPosition = cameraView.cameraPosition == XBCameraPositionBack ? XBCameraPositionFront : XBCameraPositionBack;
    
    if ([[filtersName objectAtIndex:self.filterIndex] isEqualToString:@"Sharpen"]) {
        GLKMatrix2 rawTexCoordTransform = [self rawTextureCoordinatesTransform];
        GLKProgram *program = [cameraView.programs objectAtIndex:1];
        [program setValue:(void *)&rawTexCoordTransform forUniformNamed:@"u_rawTexCoordTransform"];
    }
}

@end
