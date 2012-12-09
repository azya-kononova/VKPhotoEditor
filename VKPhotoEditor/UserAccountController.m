//
//  UserAccountController.m
//  VKPhotoEditor
//
//  Created by Kate on 11/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "UserAccountController.h"
#import "VKRequestExecutor.h"
#import "NSArray+Helpers.h"
#import "UIView+Helpers.h"

@interface UserAccountController () {
    UIButton *followButton;
}
@end

@implementation UserAccountController

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super initWithProfile:_profile]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    followButton = self.profileHeaderView.centralButton;
    [self.userMenuView.actionButton setTitle:@"Block user" forState:UIControlStateNormal];
    [followButton setBackgroundImage:[UIImage imageNamed:@"FollowBtn_pressed.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [followButton setTitle:@"Following" forState:UIControlStateSelected | UIControlStateHighlighted];
}

#pragma mark - actions

- (void)profileHeaderViewDidTapButton:(ProfileHeaderView *)view
{
    if (blocked) {
        [adapter start:[service unblockUser:self.profile.accountId] onSuccess:@selector(exec:didUnblockUser:) onError:nil];
        return;
    }
    VKRequestExecutor *exec = followButton.selected ? [service unfollowUser:self.profile.accountId]  : [service followUser:self.profile.accountId] ;
    [adapter start:exec onSuccess:@selector(exec:didFollowUser:) onError:@selector(exec:didFailFollowUser:) ];
    self.profileHeaderView.centralButton.selected = !self.profileHeaderView.centralButton.selected;
    followedByMe = !followedByMe;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setBlockedState:(BOOL)_blocked
{
    blocked = _blocked;
    self.profileHeaderView.blockButton.hidden = !blocked;
    followButton.hidden = !self.profileHeaderView.blockButton.hidden;
}

#pragma mark - UserHeaderViewDelegate

- (void)userMenuViewDidTapAction:(UserMenuView *)view
{
    [adapter start:[service blockUser:self.profile.accountId] onSuccess:@selector(exec:didBlockUser:) onError:nil];
    [super userMenuViewDidCancel:view];
}

#pragma mark - executor handlers

- (void)exec:(VKRequestExecutor *)exec didFollowUser:(id)data
{
    [self updateInfo];
}

- (void)exec:(VKRequestExecutor*)exec didFailFollowUser:(id)data
{
    followButton.selected = !followButton.selected;
    followedByMe = !followedByMe;
}

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data
{
    [super exec:exec didGetUser:data];
    followButton.selected = followedByMe;
    [self setBlockedState:blocked];
}

- (void)exec:(VKRequestExecutor*)exec didBlockUser:(id)data
{
    [self setBlockedState:YES];
}

- (void)exec:(VKRequestExecutor *)exec didUnblockUser:(id)data
{
    [self setBlockedState:NO];
}

@end
