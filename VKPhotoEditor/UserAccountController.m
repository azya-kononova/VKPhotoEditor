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
    
}
@end

@implementation UserAccountController
@synthesize backButton;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super initWithProfile:_profile]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    backButton.bgImagecaps = CGSizeMake(15, 0);
    [self.centralButton setBackgroundImage:[UIImage imageNamed:@"FollowBtn_pressed.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.centralButton setTitle:@"Following" forState:UIControlStateSelected | UIControlStateHighlighted];
}

#pragma mark - actions

- (IBAction)followAccount:(id)sender
{
    VKRequestExecutor *exec = self.centralButton.selected ?
            [service unfollowUser:self.profile.accountId]  : [service followUser:self.profile.accountId] ;
    [adapter start:exec onSuccess:nil onError:@selector(exec:didFailFollowUser:) ];
    self.centralButton.selected = !self.centralButton.selected;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - executor handlers

- (void)exec:(VKRequestExecutor*)exec didFailFollowUser:(id)data
{
    self.centralButton.selected = !self.centralButton.selected;
}

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data
{
    [super exec:exec didGetUser:data];
    self.centralButton.selected = followedByMe;
}

@end
