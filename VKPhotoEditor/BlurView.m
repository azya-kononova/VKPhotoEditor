//
//  BlurView.m
//  VKPhotoEditor
//
//  Created by asya on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "BlurView.h"
#import "TableViewPopover.h"
#import "TablePopoverCell.h"
#import "GPUImageGaussianSelectiveBlurFilter.h"
#import "GPUImageTiltShiftFilter.h"

@interface BlurView ()<TableViewPopoverDataSource, TableViewPopoverDelegate, UIGestureRecognizerDelegate>
@end

@implementation BlurView {
    TableViewPopover *popover;
    NSArray *blurModes;
}

@synthesize delegate, pinch, mode;

- (id)initWithCenter:(CGPoint)center margin:(CGFloat)margin
{
    self = [super init];
    if (self) {
        popover = [TableViewPopover loadFromNIB];
        popover.delegate = self;
        popover.dataSource = self;
        popover.originPoint = CGPointMake(0, center.y - margin);
        [self addSubview:popover];
        
        blurModes = [self setBlurModes];
        
        pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchBlur:)];
        pinch.delegate = self;
        
        self.frame = CGRectMake(center.x, margin,  popover.frame.size.width,  popover.frame.size.height + margin);
    }
    return self;
}

- (NSArray *)setBlurModes
{
    NSMutableArray *modes = [NSMutableArray array];
    
    [modes addObject:MakeBlurMode(@"TiltShiftFilterName", @"blur_line.png", @"blur_line_icon.png")];
    [modes addObject:MakeBlurMode(@"GaussianSelectiveBlurFilterName", @"blur_round.png", @"blur_round_icon.png")];
    [modes addObject:MakeBlurMode(nil, @"blur_off.png", @"blur_off_icon.png")];

    return modes;
}

- (void)pinchBlur:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [delegate blurViewDidBeginBlurScaleEditing:self];
            break;
        case UIGestureRecognizerStateChanged:
            [delegate blurView:self didChangeBlurScale:recognizer.scale];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [delegate blurViewDidFinishBlurScaleEditing:self];
            break;
        default:
            break;
    }
}

- (void)reloadData
{
    [popover reloadData];
}

- (void)show:(BOOL)isShown
{
    [popover show:isShown];
}

- (BOOL)isShown
{
    return [popover isShown];
}

- (void)setModeWithFilter:(id)filter
{
    if ([filter isKindOfClass:[GPUImageTiltShiftFilter class]]) {
        mode = [blurModes objectAtIndex:0];
    }
    if ([filter isKindOfClass:[GPUImageGaussianSelectiveBlurFilter class]]) {
        mode = [blurModes objectAtIndex:1];
    }
    if (!filter) {
        mode = [blurModes objectAtIndex:2];
    }
    
    [delegate blurView:self didFinishWithBlurMode:mode blurFilter:filter];
}

#pragma mark - TableViewPopoverDataSource

- (UITableViewCell*)tableViewPopover:(TableViewPopover*)view cellForRowAtIndex:(NSInteger)index inTableView:(UITableView*)tableView
{
    TablePopoverCell *cell = [TablePopoverCell dequeOrCreateInTable:tableView];
    cell.imageView.image = [[blurModes objectAtIndex:index] image];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableViewPopoverRowsNumber:(TableViewPopover *)view
{
    return blurModes.count;
}

#pragma mark - TableViewPopoverDelegate

- (void)tableViewPopover:(TableViewPopover *)view didSelectRowAtIndex:(NSInteger)index
{
    [popover show:NO];
    
    mode = [blurModes objectAtIndex:index];
    [delegate blurView:self didFinishWithBlurMode:mode blurFilter:mode.filter];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return mode.hasFilter && !self.isShown;
}

@end
