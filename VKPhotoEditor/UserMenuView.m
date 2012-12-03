//
//  UserMenuView.m
//  VKPhotoEditor
//
//  Created by Kate on 12/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserMenuView.h"
#import "UIView+Helpers.h"

@implementation UserMenuView
@synthesize delegate;
@synthesize contentView;
@synthesize actionButton;
@synthesize cancelButton;

- (void)awakeFromNib
{
    actionButton.bgImagecaps = CGSizeMake(20, 20);
    cancelButton.bgImagecaps = CGSizeMake(20, 20);
    [contentView moveTo:CGPointMake(0, -contentView.frame.size.height)];
    self.hidden = YES;
}

- (void)show:(BOOL)show
{
    if (show) self.hidden = NO;
    
    [UIView animateWithDuration:0.6 delay:0 options: UIViewAnimationCurveEaseIn animations:^(void) {
        [contentView moveTo:CGPointMake(0, show ? 0 : -self.frame.size.height)];
    } completion:^(BOOL finished){ if (!show) self.hidden = YES; }];
}

#pragma mark - actions

- (IBAction)cancel
{
    [delegate userMenuViewDidCancel:self];
}

- (IBAction)action
{
    [delegate userMenuViewDidTapAction:self];
}

@end
