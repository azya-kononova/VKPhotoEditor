//
//  ProfileController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileController.h"
#import "PhotoCell.h"
#import "PhotoHeaderView.h"
#import "VKPhoto.h"
#import "RequestExecutorDelegateAdapter.h"
#import "UserPhotoList.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "UIView+Helpers.h"
#import "CALayer+Animations.h"
#import "PhotoView.h"

@interface ProfileController ()
@end

@implementation ProfileController {
    VKConnectionService *service;
    CGFloat uploadWidth;
}

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super initWithProfile:_profile]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAvatarList) name:VKRequestDidUpdateAvatarNotification object:nil];
        service = [VKConnectionService shared];
    }
    return self;
}

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    self.profileHeaderView.backButton.hidden = YES;
}

#pragma mark - UserHeaderViewDelegate

- (void)userMenuViewDidTapAction:(UserMenuView *)view
{
    [self.delegate profileBaseControllerDidLogout:self];
}

#pragma mark - ProfileHeaderViewDelegate

- (void)profileHeaderViewDidTapButton:(ProfileHeaderView *)view
{
    if (!self.avatarsList.photos.count) {
        [self.delegate profileBaseControllerWantLoadAvatar:self];
        return;
    }
    VKPhoto *selectedPhoto = [self.avatarsList.photos objectAtIndex:self.profileHeaderView.avatarTheaterView.displayedItemIndex];
    VKRequestExecutor *exec = [service updateUserPic:selectedPhoto.photoId];
    [adapter start:exec onSuccess:@selector(VKRequestExecutor:didUpdatePhoto:) onError:nil];
}

#pragma mark - actions

- (IBAction)openProfile
{
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didUpdatePhoto:(id)value
{
    [photosTableView reloadData];
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [self.photosList deletePhoto:[ids objectAtIndex:0]];
}

#pragma mark - UITableViewDataSource
//
//- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section
//{
//    return isUploading ? uploadingContainerView.frame.size.height : 0;
//}
//
//- (UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
//{
//    return isUploading ? uploadingContainerView : nil;
//}

@end
