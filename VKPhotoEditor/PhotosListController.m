//
//  PhotosListControllerController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotosListController.h"
#import "VKTabBar.h"
#import "UIView+Helpers.h"
#import "ProfileController.h"
#import "VKConnectionService.h"
#import "ChoosePhotoView.h"
#import "UIViewController+Transitions.h"
#import "CroppingViewController.h"
#import "PhotoEditController.h"
#import "AllPhotosController.h"
#import "UINavigationController+Transistions.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345

@interface PhotosListController () <VKTabBarDelegate, ChoosePhotoViewDelegate, ProfileControllerDelegate, AllPhotosControllerDelegate>
@end

@implementation PhotosListController {
    VKTabBar *tabBar;
    NSArray *controllers;
    VKRequestExecutor *exec;
    VKConnectionService *service;
    ChoosePhotoView *choosePhotoView;
    
    ImageToUpload *imageToUpload;
    BOOL isAvatar;
    
    UINavigationController *navCtrl;
    AllPhotosController *allPhotosCtrl;
    ProfileController *profileCtrl;
}

- (id)initWithImageToUpload:(ImageToUpload*)image
{
    if (self = [super init]) {
        imageToUpload = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    service = [VKConnectionService shared];
    profileCtrl = [[ProfileController alloc] initWithProfile:service.profile];
    profileCtrl.delegate = self;
    
    allPhotosCtrl = [AllPhotosController new];
    allPhotosCtrl.delegate = self;
    
    navCtrl = [[[NSBundle mainBundle] loadNibNamed:@"VKNavigationController" owner:self options:nil] objectAtIndex:0];
    navCtrl.viewControllers = [NSArray arrayWithObject:allPhotosCtrl];
    
    UINavigationController *navCtrl1 = [[[NSBundle mainBundle] loadNibNamed:@"VKNavigationController" owner:self options:nil] objectAtIndex:0];
    navCtrl1.viewControllers = [NSArray arrayWithObject:profileCtrl];
    
    [profileCtrl view];
    
    controllers =  [NSArray arrayWithObjects:navCtrl1, navCtrl, nil];
    
    tabBar = [VKTabBar loadFromNIB];
    [tabBar moveBy:CGPointMake(0, self.view.frame.size.height - tabBar.frame.size.height)];
    [self.view addSubview:tabBar];
    
    tabBar.delegate = self;
    tabBar.state = TabBarStateProfile;
    
    choosePhotoView = [ChoosePhotoView loadFromNIB];
    [self.view addSubview:choosePhotoView];
    choosePhotoView.delegate = self;
    
    if (imageToUpload) [profileCtrl uploadImage:imageToUpload];
}

#pragma mark - VKTabBarDelegate

- (void)VKTabBar:(VKTabBar *)_tabBar didSelectIndex:(NSInteger)index
{
    if (navCtrl.viewControllers.count == 2) {
        [navCtrl popToRootViewControllerAnimated:YES];
    }
    
    UIView* currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    UIViewController *ctrl = [controllers objectAtIndex:index];
    [ctrl.view resizeTo:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - (_tabBar.frame.size.height))];
    ctrl.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    
    [self.view insertSubview:ctrl.view belowSubview:tabBar];
}

- (void)VKTabBarDidTapCentral:(VKTabBar *)tabBar
{
    isAvatar = NO;
    [choosePhotoView show:YES withExitButton:NO animated:YES];
}

#pragma mark - ProfileControllerDelegate

- (void)profileControllerDidOpenProfile:(ProfileController *)ctrl
{
    isAvatar = YES;
    [choosePhotoView show:YES withExitButton:YES animated:YES];
}

- (void)profileControllerDidBack:(ProfileController *)ctrl
{
    tabBar.state = TabBarStateAllPhotos;
}

- (void)profileController:(ProfileController *)ctrl didTapHashTag:(NSString *)hashTag
{
    tabBar.state = TabBarStateAllPhotos;
    [allPhotosCtrl search:hashTag];
}

#pragma mark - AllPhotosControllerDelegate

- (void)allPhotosController:(AllPhotosController *)ctrl didSelectAccount:(Account *)account
{
    if (account.accountId == service.profile.accountId) {
        tabBar.state = TabBarStateProfile;
        return;
    }
//    TODO: open account
//    tabBar.state = TabBarStateUnselected;
//    ProfileController *prof_ctrl = [[ProfileController alloc] initWithAccount:(UserProfile*)account];
//    prof_ctrl.delegate = self;
//    [navCtrl pushViewController:prof_ctrl animated:YES];
}

- (void)allPhotosController:(AllPhotosController *)ctrl presenModalViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [self presentModalViewController:controller withPushDirection:kCATransitionFromRight];
}

- (void)allPhotosController:(AllPhotosController *)ctrl dismissModalViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
}

#pragma mark - ChoosePhotoViewDelegate

- (void)choosePhotoViewDidChooseCameraRoll:(ChoosePhotoView*)view
{
    [self choosePhoto];
}

- (void)choosePhotoViewDidChooseCamera:(ChoosePhotoView*)view
{
    [self takePhoto];
}

- (void)choosePhotoView:(ChoosePhotoView *)view didChooseImage:(UIImage *)image
{
    [self cropPhoto:image];
}

- (void)choosePhotoViewDidCancel:(ChoosePhotoView*)view
{
    [choosePhotoView show:NO animated:YES];
}

- (void)choosePhotoViewDidExit:(ChoosePhotoView*)view
{
    [service logout];
    [choosePhotoView show:NO animated:NO];
    [self.navigationController popToRootViewControllerTransition:UIViewAnimationTransitionFlipFromRight];
}

- (void)editPhoto:(UIImage *)image filterIndex:(NSInteger)filterIndex blurFilter:(id)blurFilter
{
    PhotoEditController *photoEditController = [[PhotoEditController alloc] initWithImage:image filterIndex:filterIndex blurFilter:blurFilter];
    photoEditController.delegate = self;
    photoEditController.isPhoto = self.isPhoto;
    photoEditController.isAvatar = isAvatar;
    
    [self.navigationController pushViewController:photoEditController animated:NO];
}

#pragma mark - PhotoEditControllerDelegate

- (void)photoEditController:(PhotoEditController *)controller didFinishWithImage:(ImageToUpload *)image
{
    [choosePhotoView show:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    [profileCtrl uploadImage:image];
    
    [super photoEditController:controller didFinishWithImage:image];
}

@end
