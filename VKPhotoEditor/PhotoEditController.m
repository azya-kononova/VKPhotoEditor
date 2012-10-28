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
#import "DemotivatorCaptionView.h"
#import "CaptionTemplateProtocol.h"
#import "UIImage+Blend.h"
#import "GPUImageNormalBlendFilter.h"
#import "ActivityView.h"
#import "ArrowView.h"

#define MAX_FONT_SIZE 100

@interface PhotoEditController () <ThumbnailsViewDelegate, ThumbnailsViewDataSource, CaptionViewDelegate, CaptionTemplateDelegate>
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
    UIView<CaptionTemplateProtocol> *captionViewTemplate;
    NSArray *captionTemplates;
    NSInteger captionTemplateIndex;
    ActivityView *activityView;
    ArrowView *arrowView;
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
@synthesize captionOverlayView;
@synthesize leftRecognizer;
@synthesize rightRecognizer;

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
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:image];
    filters = Filters.filters;
    filterView.margin = 7;
    filterView.thumbConrnerRadius = 7.0;
    [filterView reloadData];
    filterView.displayedItemIndex = filterIndex;
    [self setImageFilter:[filters objectAtIndex:filterIndex]];
   
    captionView = [CaptionView loadFromNIB];
    [captionView moveTo:CGPointMake(0, 390)];
    captionView.caption = @"Make me awesome ;)";
    captionView.hidden = YES;
    captionView.delegate = self;
    
    captionTemplates = Filters.captionViewTemplates;
    captionTemplateIndex = 0;
    [self setCaptionViewTemplate:[captionTemplates objectAtIndex:captionTemplateIndex]];
    
    [contentView addSubview:captionView];
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;
    
    activityView = [ActivityView loadFromNIB];
    [self.view addSubview:activityView];
    
    arrowView = [ArrowView loadFromNIB];
    [topView addSubview:arrowView];
    [arrowView moveTo:CGPointMake(0, 200)];
    
    filterView.highlight = YES;
}

- (void)setImageFilter:(ImageFilter*)imageFilter
{ 
    [sourcePicture removeAllTargets];
    [filter removeAllTargets];
    filter = (GPUImageFilter *)[Filters GPUFilterWithName:imageFilter.name];
    [filter setInputRotation:image.rotationMode atIndex:0];
    [sourcePicture addTarget:filter];
    [filter addTarget:imageView];
    [sourcePicture processImage];
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

- (void)setCaptionViewTemplate:(UIView<CaptionTemplateProtocol>*)_captionViewTemplate
{
    [captionViewTemplate removeFromSuperview];
    captionViewTemplate.delegate = nil;
    [captionOverlayView addSubview:_captionViewTemplate];
    _captionViewTemplate.font = captionView.selectedFont;
    _captionViewTemplate.text = captionView.caption;
    captionViewTemplate = _captionViewTemplate;
    captionViewTemplate.delegate = self;
}

- (IBAction)nextCaptionTemplate
{
    captionTemplateIndex =  ( captionTemplateIndex == captionTemplates.count - 1 ? 0 : captionTemplateIndex + 1 );
    [self setCaptionViewTemplate:[captionTemplates objectAtIndex:captionTemplateIndex]];
}

- (IBAction)prevCaptionTemplate
{
     captionTemplateIndex =  ( !captionTemplateIndex ?  captionTemplates.count - 1 : captionTemplateIndex - 1 );
    [self setCaptionViewTemplate:[captionTemplates objectAtIndex:captionTemplateIndex]];
}

- (IBAction)addCaption
{
    [arrowView showArrows];
    BOOL show = captionView.hidden;
    if (!show) [captionView resignFirstResponder];
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

    [activityView showSelf:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        CGFloat side = fmaxf(image.size.width, image.size.height);
        [captionViewTemplate removeFromSuperview];
        [captionViewTemplate resizeTo:CGSizeMake(side, side)];
        BOOL needCaptionOverlay = captionView.caption.length || captionTemplateIndex;
        UIImage *output = [[filter imageFromCurrentlyProcessedOutput] squareImageByBlendingWithView: needCaptionOverlay ? captionViewTemplate : nil];
        [activityView showSelf:NO];
        [delegate photoEditController:self didEdit:output];
    });

    
    
   }

- (IBAction)cancel
{
    if (isPhoto) {
        [delegate photoEditControllerDidRetake:self];
    } else {
        [delegate photoEditControllerDidCancel:self];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"Erorr saving photo: %@",error);
    } else {
        [delegate photoEditControllerDidCancel:self];
    }
}

#pragma mark - CaptionTemplateDelegate

- (void)captionTemplateStartEditing:(UIView<CaptionTemplateProtocol> *)captionTemplate
{
    scrollView.scrollEnabled = leftRecognizer.enabled = rightRecognizer.enabled = NO;
}

- (void)captionTemplateEndEditing:(UIView<CaptionTemplateProtocol> *)captionTemplate
{
    scrollView.scrollEnabled = leftRecognizer.enabled = rightRecognizer.enabled = YES;
}

#pragma mar CaptionView delegate

- (void)captionViewdidChange:(CaptionView *)_captionView
{
    captionViewTemplate.text = captionView.caption;
}

- (void)captionView:(CaptionView *)captionView didSetFont:(UIFont *)font
{
    captionViewTemplate.font = font;
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
