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

typedef enum {
    ProfilePhotosMode = 0,
    ProfileFollowersMode = 1,
    ProfileMentionsMode = 2,
} ProfileModeState;

@protocol ProfileBaseControllerDelegate;

@interface ProfileBaseController : UIViewController
@property (nonatomic, strong) UserProfile *profile;

@property (nonatomic, strong) PhotoList *sourceList;
@property (nonatomic, strong) UserPhotoList *photosList;
@property (nonatomic, strong) MentionList *mentionsList;
@property (nonatomic, strong) UserPhotoList *followersList;

@property (nonatomic, strong) UserPhotoList *avatarsList;

@property (nonatomic, assign) ProfileModeState state;

@property (nonatomic, strong) IBOutlet PullTableView *photosTableView;
@property (nonatomic, assign) id<ProfileBaseControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *noPhotoLabel;

// header view
@property (nonatomic, strong) IBOutlet TheaterView *avatarTheaterView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet FlexibleButton *centralButton;
@property (nonatomic, strong) IBOutlet UIView *headerTopView;
@property (nonatomic, strong) IBOutlet UIView *headerBottomView;
@property (nonatomic, strong) IBOutlet UIImageView *noAvatarImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *avatarActivity;
@property (nonatomic, strong) IBOutlet UILabel *noAvatarLabel;

- (id)initWithProfile:(UserProfile*)profile;
- (void)reloadAvatarList;

- (IBAction)leftOptionSelected;
- (IBAction)rightOptionSelected;
@end

@protocol ProfileBaseControllerDelegate
- (void)profileBaseControllerDidOpenProfile:(ProfileBaseController*)ctrl;
- (void)profileBaseControllerDidBack:(ProfileBaseController*)ctrl;
- (void)profileBaseController:(ProfileBaseController*)ctrl didTapHashTag:(NSString*)hashTag;
- (void)profileBaseController:(ProfileBaseController*)ctrl didReplyToPhoto:(VKPhoto *)photo;
@end