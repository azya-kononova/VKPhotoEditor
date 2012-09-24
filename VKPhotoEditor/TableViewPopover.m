//
//  SizePopover.m
//  Mascotte
//
//  Created by Ekaterina Petrova on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableViewPopover.h"
#import "UIView+Helpers.h"

@interface TableViewPopover () <UITableViewDelegate, UITableViewDataSource>
@end


@implementation TableViewPopover

@synthesize delegate;
@synthesize dataSource;
@synthesize tableView;
@synthesize backgroundView;
@synthesize originPoint;
@synthesize margin;

- (void)awakeFromNib
{
    backgroundView.layer.cornerRadius = 8;
    self.hidden = YES;
    [self moveTo:CGPointMake(self.frame.origin.x, margin)];
}

- (void)setOriginPoint:(CGPoint)_originPoint
{
    originPoint = _originPoint;
    [self moveTo:CGPointMake(originPoint.x, margin)];
    self.alpha = 0;
}

- (void)show:(BOOL)show
{
    if (self.hidden == !show) return;
    
    self.hidden = NO;
    
    if (show && !originPoint.y) [self moveBy:CGPointMake(0, originPoint.y)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = show;
        [self moveTo:CGPointMake(originPoint.x, show ? originPoint.y : margin)];
    } completion:^(BOOL finished) {
        self.hidden = !show;
        if (!show) [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }];
}

- (void)reloadData
{
    [tableView reloadData];
}

- (BOOL)isShown
{
    return !self.hidden;
}

- (CGFloat)margin
{
    return margin ? margin : -CGRectGetHeight(self.frame);
}
                             
#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource tableViewPopoverRowsNumber:self];
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dataSource tableViewPopover:self cellForRowAtIndex:indexPath.row inTableView:_tableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate tableViewPopover:self didSelectRowAtIndex:indexPath.row];
}

@end
