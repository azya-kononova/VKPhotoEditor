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
#import "VKRequestExecutor.h"
#import "VKConnectionService.h"
#import "ChoosePhotoView.h"
#import "UIViewController+Transitions.h"
#import "CroppingViewController.h"
#import "PhotoEditController.h"
#import "AllPhotosController.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345

@interface PhotosListController () <VKTabBarDelegate, VKRequestExecutorDelegate, ChoosePhotoViewDelegate, ProfileControllerDelegate, AllPhotosControllerDelegate>
@end

@implementation PhotosListController {
    VKTabBar *tabBar;
    NSArray *controllers;
    VKRequestExecutor *exec;
    VKConnectionService *service;
    ChoosePhotoView *choosePhotoView;
    UIImage *imageToUpload;
    BOOL isPhoto;
    UINavigationController *navCtrl;
    AllPhotosController *allPhotosCtrl;
}


- (id)initWithImageToUpload:(UIImage *)image
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
    ProfileController *profileCtrl = [[ProfileController alloc] initWithAccount:service.account];
    profileCtrl.delegate = self;
    
    allPhotosCtrl = [AllPhotosController new];
    allPhotosCtrl.delegate = self;
    navCtrl = [[UINavigationController alloc] initWithRootViewController:allPhotosCtrl];
    [navCtrl setNavigationBarHidden:YES animated:NO];
    controllers =  [NSArray arrayWithObjects:profileCtrl, navCtrl, nil];
    if (imageToUpload) [profileCtrl uploadImage:imageToUpload];
    
    tabBar = [VKTabBar loadFromNIB];
    [tabBar moveBy:CGPointMake(0, self.view.frame.size.height - tabBar.frame.size.height)];
    [self.view addSubview:tabBar];
    
    tabBar.delegate = self;
    tabBar.state = TabBarStateProfile;
    
    choosePhotoView = [ChoosePhotoView loadFromNIB];
    [self.view addSubview:choosePhotoView];
    choosePhotoView.delegate = self;
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
    [choosePhotoView show:YES withExitButton:NO animated:YES];
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    NSLog(@"%@", value);
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    
}

#pragma mark - ProfileControllerDelegate

- (void)profileControllerDidOpenProfile:(ProfileController *)ctrl
{
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
    if (account.accountId == service.account.accountId) {
        tabBar.state = TabBarStateProfile;
        return;
    }
    tabBar.state = TabBarStateUnselected;
    ProfileController *prof_ctrl = [[ProfileController alloc] initWithAccount:(UserProfile*)account];
    prof_ctrl.delegate = self;
    [navCtrl pushViewController:prof_ctrl animated:YES];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - PhotoEditControllerDelegate

- (void)photoEditController:(PhotoEditController *)controller didEdit:(UIImage *)image
{
    [choosePhotoView show:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    ProfileController *ctrl = [controllers objectAtIndex:0];
    [ctrl uploadImage:image];
}

@end
