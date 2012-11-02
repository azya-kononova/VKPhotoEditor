//
//  InformationView.m
//  Radario
//
//  Created by Ekaterina Petrova on 5/24/12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "InformationView.h"
#import "CALayer+Animations.h"

#define INFORMATION_VIEW_AUTO_DELAY 3

@interface InformationView () <UIGestureRecognizerDelegate>
@end

@implementation InformationView {
    IBOutlet UILabel *messageLabel;
    IBOutlet UIView *bgView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    bgView.layer.cornerRadius = 8.0;
    
    self.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelfAndStopTimer)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)hideSelfAfterTimeout:(NSTimeInterval)timeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (timeout > 0) {
        [self performSelector:@selector(hideSelf) withObject:nil afterDelay:timeout];
    }
}

- (void)showMessage:(NSString *)message withTimeout:(NSTimeInterval)timeout
{
    messageLabel.text = message;
    [self showSelf:YES];
    [self hideSelfAfterTimeout:timeout];
    
}

- (void)showMessage:(NSString *)message
{
    [self showMessage:message withTimeout:INFORMATION_VIEW_AUTO_DELAY];
}

- (void)showSelf:(BOOL)show
{
    [self.layer fade].duration = 0.15;
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