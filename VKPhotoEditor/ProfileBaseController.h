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

@protocol ProfileBaseControllerDelegate;

@interface ProfileBaseController : UIViewController
@property (nonatomic, strong) UserProfile *profile;
@property (nonatomic, strong) UserPhotoList *photosList;
@property (nonatomic, strong) UserPhotoList *avatarsList;

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

- (id)initWithProfile:(UserProfile*)profile;
- (void)showAvatar:(RemoteImage*)avatar animated:(BOOL)animated;

- (IBAction)leftOptionSelected;
- (IBAction)rightOptionSelected;
@end

@protocol ProfileBaseControllerDelegate
- (void)profileBaseControllerDidOpenProfile:(ProfileBaseController*)ctrl;
- (void)profileBaseControllerDidBack:(ProfileBaseController*)ctrl;
- (void)profileBaseController:(ProfileBaseController*)ctrl didTapHashTag:(NSString*)hashTag;
@end