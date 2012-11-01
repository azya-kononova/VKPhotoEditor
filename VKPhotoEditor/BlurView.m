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


@interface BlurView ()<TableViewPopoverDataSource, TableViewPopoverDelegate, UIGestureRecognizerDelegate>
@end

@implementation BlurView {
    TableViewPopover *popover;
    NSArray *blurModes;
    BlurMode *currentMode;
    CGFloat blurScale;
}

@synthesize delegate, pinch;

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
    
    [modes addObject:MakeBlurMode(@"TiltShiftFilter", @"blur_line.png", @"blur_line_icon.png")];
    [modes addObject:MakeBlurMode(@"GaussianSelectiveBlurFilterName", @"blur_round.png", @"blur_round_icon.png")];
    [modes addObject:MakeBlurMode(nil, @"blur_off.png", @"blur_off_icon.png")];
    
    return modes;
}

- (void)pinchBlur:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            blurScale = recognizer.scale;
            break;
        case UIGestureRecognizerStateChanged:
            blurScale = recognizer.scale - blurScale;
            [delegate blurView:self didChangeBlurScale:blurScale];
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
    
    currentMode = [blurModes objectAtIndex:index];
    [delegate blurView:self didFinishWithBlurMode:currentMode];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return currentMode.filter != nil && !self.isShown;
}

@end
