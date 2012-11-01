//
//  VKTableView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "StickyHeaderTableView.h"

@implementation StickyHeaderTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.tableHeaderView.frame;
    rect.origin.y = MIN(0, self.contentOffset.y);
    self.tableHeaderView.frame = rect;
}

@end
