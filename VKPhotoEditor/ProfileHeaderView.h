//
//  ProfileHeaderView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 12/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheaterView.h"
#import "FlexibleButton.h"

typedef enum {
    ProfileHeaderViewStateFollowing,
    ProfileHeaderViewStateFull,
    ProfileHeaderViewStateCompact,
    ProfileHeaderViewStateHeader,
} ProfileHeaderViewState;

typedef enum {
    ProfileHeaderViewPhotosMode = 0,
    ProfileHeaderViewFollowersMode = 1,
    ProfileHeaderViewsMentiosMode = 2,
} ProfileHeaderViewMode;

@protocol  ProfileHeaderViewDelegate;

@interface ProfileHeaderView : UIView

@property (nonatomic, assign) id<ProfileHeaderViewDelegate> delegate;

@property (nonatomic, assign) ProfileHeaderViewState state;
@property (nonatomic, assign) ProfileHeaderViewMode mode;

@property (nonatomic, strong) IBOutlet TheaterView *avatarTheaterView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet FlexibleButton *centralButton;
@property (nonatomic, strong) IBOutlet UIView *headerTopView;
@property (nonatomic, strong) IBOutlet UIView *headerBottomView;
@property (nonatomic, strong) IBOutlet UIImageView *noAvatarImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *avatarActivity;
@property (nonatomic, strong) IBOutlet UILabel *noAvatarLabel;
@property (nonatomic, strong) IBOutlet UILabel *photosLabelCount;
@property (nonatomic, strong) IBOutlet UILabel *followersLabelCount;
@property (nonatomic, strong) IBOutlet UILabel *mentionsLabelCount;
@property (nonatomic, strong) IBOutlet UIView *headerCentralView;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *userMenuButton;

@property (nonatomic, strong) IBOutlet UIView *mentionsView;
@property (nonatomic, strong) IBOutlet UIView *followersView;
@property (nonatomic, strong) IBOutlet UIView *photosView;
@property (nonatomic, strong) IBOutlet UIButton *gridButton;

- (IBAction)changeMode:(UIButton*)sender;
- (IBAction)centerAction;
- (IBAction)back;
- (IBAction)showUserMenu:(UIButton*)sender;
- (IBAction)changeGridMode:(UIButton*)sender;

@end

@protocol  ProfileHeaderViewDelegate
- (void)profileHeaderView:(ProfileHeaderView*)view didChangeMode:(ProfileHeaderViewMode)mode;
- (void)profileHeaderViewDidTapButton:(ProfileHeaderView*)view;
- (void)profileHeaderViewDidBack:(ProfileHeaderView*)view;
- (void)profileHeaderView:(ProfileHeaderView*)view didOpenUserMenu:(BOOL)open;
- (void)profileHeaderViewDidSwitchGridMode:(ProfileHeaderView*)view;
@end;