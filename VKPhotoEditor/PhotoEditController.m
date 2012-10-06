//
//  PhotoEditController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoEditController.h"
#import "FlexibleButton.h"
#import "Filters.h"
#import "UIColor+VKPhotoEditor.h"
#import "CaptionView.h"
#import "UIView+Helpers.h"
#import "UIView+NIB.h"
#import "ImageFilter.h"
#import "GPUImagePicture.h"
#import "SPUserResizableView.h"
#import "UIImage+GPUOrientation.h"

#define MAX_FONT_SIZE 100

@interface PhotoEditController () <ThumbnailsViewDelegate, ThumbnailsViewDataSource, CaptionViewDelegate, UIGestureRecognizerDelegate, SPUserResizableViewDelegate>
@end

@implementation PhotoEditController {
    NSArray *filters;
    CaptionView *captionView;
    CGPoint oldContentOffset;
    UIImage *image;
    BOOL isPhoto;
    NSInteger filterIndex;
    GPUImagePicture *sourcePicture;
    GPUImageFilter *filter;
}

@synthesize saveButton;
@synthesize retakeButton;
@synthesize captionButton;
@synthesize filterView;
@synthesize contentView;
@synthesize scrollView;
@synthesize imageView;
@synthesize topView;
@synthesize delegate;
@synthesize captionLabel;
@synthesize labelView;

- (id)initWithImage:(UIImage *)_image filterIndex:(NSInteger)_filterIndex
{
    self = [super init];
    if (self) {
        image = _image;
        filterIndex = _filterIndex;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    saveButton.bgImagecaps = CGSizeMake(23, 0);
    retakeButton.bgImagecaps = CGSizeMake(23, 20);
    captionButton.bgImagecaps = CGSizeMake(23, 20);
    [captionButton setBackgroundImage:[UIImage imageNamed:@"RollBtn_Prsssed"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [retakeButton setTitle:isPhoto ? @"Retake" : @"Cancel" forState:UIControlStateNormal];
    
    filters = Filters.filters;
    filterView.margin = 7;
    filterView.thumbConrnerRadius = 7.0;
    [filterView reloadData];
    filterView.displayedItemIndex = filterIndex;
    
    captionView = [CaptionView loadFromNIB];
    [captionView moveTo:CGPointMake(0, 390)];
    captionView.hidden = YES;
    captionView.delegate = self;
    [self setCaptionFont:captionView.selectedFont];
    
    [contentView addSubview:captionView];
    
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:image];
    
    [self setImageFilter:[filters objectAtIndex:filterIndex]];
    
    labelView.contentView = captionLabel;
    labelView.delegate = self;
}

- (void)setImageFilter:(ImageFilter*)imageFilter
{ 
    [sourcePicture removeAllTargets];
    [filter removeAllTargets];
    filter = [Filters GPUFilterWithName:imageFilter.name];
    [filter setInputRotation:image.rotationMode atIndex:0];
    [sourcePicture addTarget:filter];
    [filter addTarget:imageView];
    [sourcePicture processImage];
}

- (void)setCaptionFont:(UIFont*)font
{
    captionLabel.font = [UIFont fontWithName:font.fontName size:captionLabel.font.pointSize];
//    [captionLabel sizeToFit];
}

- (void)resizeScrollView:(BOOL)show notification:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [scrollView.superview convertRect:keyboardFrame fromView:scrollView.window];
    CGFloat duration;
    CGRect viewFrame = scrollView.superview.bounds;
    if (show) {
        duration = 0.30;
        viewFrame.size.height = keyboardFrame.origin.y;
    } else {
        duration = 0.45;
        viewFrame = scrollView.superview.bounds;
    }
    [UIView animateWithDuration:duration animations:^{
        scrollView.frame = viewFrame;
    }];
    scrollView.contentOffset = show ? CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height) : oldContentOffset;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    oldContentOffset = scrollView.contentOffset;
    [self resizeScrollView:YES notification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self resizeScrollView:NO notification:notification];
}

#pragma mark actions

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView
{
    scrollView.scrollEnabled = NO;
    [labelView showEditingHandles];
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
    scrollView.scrollEnabled = YES;
    [labelView hideEditingHandles];
}

- (IBAction)addCaption
{
    BOOL show = captionView.hidden;
    captionButton.selected = show;
    captionView.hidden = !show;
    CGFloat adjustHeight = captionView.frame.size.height - 15;
    [contentView expand:CGSizeMake(0, show ? adjustHeight : -adjustHeight)];
    scrollView.contentSize = contentView.frame.size;
    [UIView animateWithDuration:0.2 animations:^{
        [topView moveTo:CGPointMake(0, 0)];
    }];
    CGPoint bottomOffset = show ? CGPointMake(0, scrollView.contentSize.height - self.scrollView.bounds.size.height) : CGPointZero;
    [scrollView setContentOffset:bottomOffset animated:NO];
}

- (IBAction)save
{
    CGFloat scaleFactor = 2.0f;
    captionLabel.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
}

- (IBAction)cancel
{
    if (isPhoto) {
        [delegate photoEditControllerDidRetake:self];
    } else {
        [delegate photoEditControllerDidCancel:self];
    }
}

- (IBAction)editLabel
{
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"Erorr saving photo: %@",error);
    } else {
        [delegate photoEditControllerDidCancel:self];
    }
}

#pragma mar CaptionView delegate

- (void)captionViewdidChange:(CaptionView *)_captionView
{
    captionLabel.text = captionView.caption;
}

- (void)captionView:(CaptionView *)captionView didSetFont:(UIFont *)font
{
    [self setCaptionFont:font];
}

#pragma mark ThumbnailView datasourse

- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view
{
    return filters.count;
}

- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    ImageFilter *imageFilter = [filters objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilter.previewPath]];
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
    [self setImageFilter:[filters objectAtIndex:index]];
}

@end
