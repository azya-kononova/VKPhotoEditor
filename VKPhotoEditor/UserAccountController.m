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
//    backButton.bgImagecaps = CGSizeMake(15, 0);
    [followButton setBackgroundImage:[UIImage imageNamed:@"FollowBtn_pressed.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [followButton setTitle:@"Following" forState:UIControlStateSelected | UIControlStateHighlighted];
    [followButton setTitle:@"Follow" forState:UIControlStateNormal];
}

#pragma mark - actions

- (void)profileHeaderViewDidTapButton:(ProfileHeaderView *)view
{
    VKRequestExecutor *exec = self.profileHeaderView.centralButton.selected ?
    [service unfollowUser:self.profile.accountId]  : [service followUser:self.profile.accountId] ;
    [adapter start:exec onSuccess:nil onError:@selector(exec:didFailFollowUser:) ];
    self.profileHeaderView.centralButton.selected = !self.profileHeaderView.centralButton.selected;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - executor handlers

- (void)exec:(VKRequestExecutor*)exec didFailFollowUser:(id)data
{
    followButton.selected = !followButton.selected;
}

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data
{
    [super exec:exec didGetUser:data];
    followButton.selected = followedByMe;
}

@end
