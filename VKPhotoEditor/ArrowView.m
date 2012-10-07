//
//  ArrowView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ArrowView.h"
#import "CALayer+Animations.h"

#define delay 1

@implementation ArrowView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.hidden = YES;
    
}

- (void)hideSelfAfterTimeout:(NSTimeInterval)timeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (timeout > 0) {
        [self performSelector:@selector(hideSelf) withObject:nil afterDelay:timeout];
    }
}

- (void)showArrowsWithTimeout:(NSTimeInterval)timeout
{
    [self showSelf:YES];
    [self hideSelfAfterTimeout:timeout];
}

- (void)showArrows
{
    [self showArrowsWithTimeout:delay];
}

- (void)showSelf:(BOOL)show
{
    [self.layer fade].duration = 0.2;
    self.hidden = !show;
}

- (void)hideSelf
{
    [self showSelf:NO];
}

- (void)hideSelfAndStopTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideSelf];
}
@end
