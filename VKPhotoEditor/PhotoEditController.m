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
}
@synthesize saveButton;
@synthesize retakeButton;
@synthesize captionButton;
@synthesize filterView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    saveButton.bgImagecaps = CGSizeMake(23, 0);
    retakeButton.bgImagecaps = CGSizeMake(23, 20);
    captionButton.bgImagecaps = CGSizeMake(23, 20);
    [captionButton setBackgroundImage:[UIImage imageNamed:@"RollBtn_Prsssed"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    filters = Filters.filters;
    filterView.margin = 7;
    filterView.thumbConrnerRadius = 7.0;
    [filterView reloadData];
    
    captionView = [CaptionView loadFromNIB];
    [captionView moveTo:CGPointMake(0, 315)];
    captionView.hidden = YES;
    [self.view addSubview:captionView];
}

#pragma mark actions

- (IBAction)addCaption
{
    captionButton.selected = !captionButton.selected;
    captionView.hidden = !captionView.hidden;
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
