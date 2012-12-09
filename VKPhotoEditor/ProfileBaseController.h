//
//  ProfileBaseController.h
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "TheaterView.h"
#import "FlexibleButton.h"
#import "PullTableView.h"
#import "UserProfile.h"
#import "UserPhotoList.h"
#import "MentionList.h"
#import "RequestExecutorDelegateAdapter.h"
#import "ProfileHeaderView.h"
#import "UserMenuView.h"
#import "VKTableView.h"
#import "VKViewController.h"
#import "FollowersList.h"

@protocol ProfileBaseControllerDelegate;

@interface ProfileBaseController : VKViewController <ProfileHeaderViewDelegate, UserMenuViewDelegate> {
    BOOL followedByMe;
    BOOL blocked;
    RequestExecutorDelegateAdapter *adapter;
    VKConnectionService *service;
}

@property (nonatomic, strong) UserProfile *profile;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) PhotoList *sourceList;
@property (nonatomic, strong) UserPhotoList *photosList;
@property (nonatomic, strong) MentionList *mentionsList;
@property (nonatomic, strong) FollowersList *followersList;

@property (nonatomic, strong) UserPhotoList *avatarsList;

@property (nonatomic, strong) ProfileHeaderView *profileHeaderView;
@property (nonatomic, assign) id<ProfileBaseControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *noPhotoLabel;
@property (nonatomic, strong) UserMenuView *userMenuView;

- (id)initWithProfile:(UserProfile*)profile;
- (void)reloadAvatarList;
- (void)updateInfo;

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data;
@end

@protocol ProfileBaseControllerDelegate
- (void)profileBaseControllerDidBack:(ProfileBaseController*)ctrl;
- (void)profileBaseController:(ProfileBaseController*)ctrl didReplyToPhoto:(VKPhoto *)photo;
- (void)profileBaseControllerWantLoadAvatar:(ProfileBaseController*)ctrl;
- (void)profileBaseControllerDidLogout:(ProfileBaseController*)ctrl;
- (void)profileBaseController:(ProfileBaseController*)ctrl presenModalViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)profileBaseController:(ProfileBaseController*)ctrl dismissModalViewController:(UIViewController *)controller animated:(BOOL)animated;
@end