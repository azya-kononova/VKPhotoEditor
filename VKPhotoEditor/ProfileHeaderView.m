//
//  ProfileHeaderView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 12/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileHeaderView.h"
#import "UIView+Helpers.h"

@implementation ProfileHeaderView {
    UIView *hiddenModeView;
}
@synthesize avatarTheaterView;
@synthesize nameLabel;
@synthesize centralButton;
@synthesize headerTopView;
@synthesize headerBottomView;
@synthesize noAvatarImageView;
@synthesize avatarActivity;
@synthesize noAvatarLabel;
@synthesize photosLabelCount;
@synthesize followersLabelCount;
@synthesize mentionsLabelCount;
@synthesize headerCentralView;
@synthesize mode;
@synthesize state;
@synthesize delegate;
@synthesize userMenuButton;
@synthesize photosView;
@synthesize followersView;
@synthesize mentionsView;
@synthesize gridButton;

- (void)awakeFromNib
{
    centralButton.bgImagecaps = CGSizeMake(23, 0);
    [userMenuButton setImage:[UIImage imageNamed:@"HeaderArrow_active.png"] forState:UIControlStateSelected | UIControlStateHighlighted ];
    hiddenModeView = photosView;
    hiddenModeView.hidden = YES;
}

#pragma mark - actions

- (IBAction)changeGridMode:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [delegate profileHeaderViewDidSwitchGridMode:self];
}

- (IBAction)showUserMenu:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [delegate profileHeaderView:self didOpenUserMenu:sender.selected];
}

- (IBAction)back
{
    [delegate profileHeaderViewDidBack:self];
}

- (IBAction)centerAction
{
    [delegate profileHeaderViewDidTapButton:self];
}

- (IBAction)changeMode:(UIButton*)sender
{
    self.mode = sender.tag;
    
    UIView *containerView = sender.superview;
    [hiddenModeView moveTo:CGPointMake(containerView.frame.origin.x, containerView.frame.origin.y)];
    containerView.hidden = YES;
    hiddenModeView.hidden = NO;
    hiddenModeView = containerView;
}

- (void)setMode:(ProfileHeaderViewMode)_mode
{
    if (mode == _mode)
        return;
    
    mode = _mode;
    [delegate profileHeaderView:self didChangeMode:mode];
}

- (UIView*)addView:(UIView*)view afterView:(UIView*)previosView
{
    [self addSubview:view];
    [view moveTo:CGPointMake(0, previosView ? previosView.frame.origin.y + previosView.frame.size.height : 0)];
    return view;
    
}

- (void)setState:(ProfileHeaderViewState)_state
{
    if (state == _state)
        return;
    
    state = _state;
    [headerCentralView removeFromSuperview];
    [headerBottomView removeFromSuperview];
    [headerCentralView removeFromSuperview];
    UIView *lastView;
    
    switch (state) {
        case ProfileHeaderViewStateFollowing:
            [self addView:headerTopView afterView:nil];
            lastView = [self addView:headerBottomView afterView:headerTopView];
            break;
        case ProfileHeaderViewStateHeader:
            lastView = [self addView:headerTopView afterView:nil];
            break;
        case ProfileHeaderViewStateCompact:
            noAvatarLabel.hidden = NO;
            avatarTheaterView.hidden = YES;
            [self addView:headerTopView afterView:nil];
            [self addView:headerCentralView afterView:headerTopView];
            [headerCentralView resizeTo:noAvatarImageView.frame.size];
            lastView = [self addView:headerBottomView afterView:headerCentralView];
            break;
        case ProfileHeaderViewStateFull:
            noAvatarLabel.hidden = YES;
            avatarTheaterView.hidden = NO;
            [self addView:headerTopView afterView:nil];
            [self addView:headerCentralView afterView:headerTopView];
            [headerCentralView resizeTo:avatarTheaterView.frame.size];
            lastView = [self addView:headerBottomView afterView:headerCentralView];
            break;
        default:
            break;
    }
    
    [self resizeTo:CGSizeMake(320, lastView.frame.origin.y + lastView.frame.size.height)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [nameLabel sizeThatFits:CGSizeMake(320, 44)];
    size.width += 5;
    [nameLabel resizeTo:size];
    [nameLabel moveTo:CGPointMake(round((320 - nameLabel.frame.size.width)/2), 5)];
    [userMenuButton moveTo:CGPointMake(nameLabel.frame.size.width + nameLabel.frame.origin.x - 5, 0)];
}

@end
