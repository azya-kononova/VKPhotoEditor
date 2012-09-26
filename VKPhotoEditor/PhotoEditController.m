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
#import "ThumbnailsView.h"
#import "UIColor+VKPhotoEditor.h"
#import "CaptionView.h"
#import "UIView+Helpers.h"
#import "UIView+NIB.h"

@interface PhotoEditController () <ThumbnailsViewDelegate, ThumbnailsViewDataSource>
@end

@implementation PhotoEditController {
    NSArray *filters;
    CaptionView *captionView;
    CGPoint oldContentOffset;
}
@synthesize saveButton;
@synthesize retakeButton;
@synthesize captionButton;
@synthesize filterView;
@synthesize contentView;
@synthesize scrollView;
@synthesize imageView;
@synthesize topView;

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
    
    filters = Filters.filters;
    filterView.margin = 7;
    filterView.thumbConrnerRadius = 7.0;
    [filterView reloadData];
    
    captionView = [CaptionView loadFromNIB];
    [captionView moveTo:CGPointMake(0, 390)];
    captionView.hidden = YES;
    [contentView addSubview:captionView];
    
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;
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

- (void)thumbnailsView:(ThumbnailsView*)view didScrollToItemWithIndex:(NSUInteger)index
{
    
}
- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index
{
    
}

@end
