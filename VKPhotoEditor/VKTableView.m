//
//  VKTableView.m
//  VKPhotoEditor
//
//  Created by Kate on 12/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKTableView.h"
#import "UIView+Helpers.h"

@implementation VKTableView
@synthesize uploadingView;

- (void)setTableHeaderView:(UIView *)tableHeaderView
{
    [super setTableHeaderView:tableHeaderView];
    [self sendSubviewToBack:tableHeaderView];
    [uploadingView moveTo:CGPointMake(0,self.tableHeaderView.frame.size.height)];
    
    for (UIView* sv in self.subviews) {
        NSLog(@"%@", sv);
    }
}

- (void)setUploadingView:(UploadingView *)_uploadingView
{
    if (uploadingView == _uploadingView)
        return;
    
    [uploadingView removeFromSuperview];
    uploadingView = _uploadingView;
    if (!uploadingView) return;
    
    [self addSubview:uploadingView];
    [uploadingView moveTo:CGPointMake(0,self.tableHeaderView.frame.size.height)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!uploadingView) return;
    
    CGRect rect = self.uploadingView.frame;
    rect.origin.y = MAX(self.tableHeaderView.frame.size.height, self.contentOffset.y);
    self.uploadingView.frame = rect;
}

@end
