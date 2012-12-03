//
//  ProfileBaseController.h
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheaterView.h"
#import "FlexibleButton.h"
#import "PullTableView.h"
#import "UserProfile.h"
#import "UserPhotoList.h"
#import "MentionList.h"
#import "RequestExecutorDelegateAdapter.h"
#import "ProfileHeaderView.h"

@protocol ProfileBaseControllerDelegate;

@interface ProfileBaseController : UIViewController <ProfileHeaderViewDelegate> {
    BOOL followedByMe;
    RequestExecutorDelegateAdapter *adapter;
    VKConnectionService *service;
}

@property (nonatomic, strong) UserProfile *profile;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) PhotoList *sourceList;
@property (nonatomic, strong) UserPhotoList *photosList;
@property (nonatomic, strong) MentionList *mentionsList;
@property (nonatomic, strong) UserPhotoList *followersList;

@property (nonatomic, strong) UserPhotoList *avatarsList;

@property (nonatomic, strong) ProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) IBOutlet PullTableView *photosTableView;
@property (nonatomic, assign) id<ProfileBaseControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *noPhotoLabel;

- (id)initWithProfile:(UserProfile*)profile;
- (void)reloadAvatarList;

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data;
@end

@protocol ProfileBaseControllerDelegate
- (void)profileBaseControllerDidOpenProfile:(ProfileBaseController*)ctrl;
- (void)profileBaseControllerDidBack:(ProfileBaseController*)ctrl;
- (void)profileBaseController:(ProfileBaseController*)ctrl didTapHashTag:(NSString*)hashTag;
- (void)profileBaseController:(ProfileBaseController*)ctrl didReplyToPhoto:(VKPhoto *)photo;
@end