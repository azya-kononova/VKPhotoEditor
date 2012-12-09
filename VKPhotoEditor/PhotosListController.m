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
#import "UserAccountController.h"
#import "ListManagerBaseController.h"
#import "RepliesViewController.h"
#import "VKViewController.h"
#import "NewsViewController.h"
#import "UploadingView.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345


@interface PhotosListController () <VKTabBarDelegate, ChoosePhotoViewDelegate, ProfileBaseControllerDelegate, ListManagerBaseControllerDelegate, VKRequestExecutorDelegate>

@end

@implementation PhotosListController {
    VKTabBar *tabBar;
    NSArray *controllers;
    VKRequestExecutor *uploadExec;
    VKConnectionService *service;
    ChoosePhotoView *choosePhotoView;
    
    ImageToUpload *imageToUpload;
    BOOL isAvatar;
    VKPhoto *replyToPhoto;
    
    AllPhotosController *allPhotosCtrl;
    ProfileController *profileCtrl;
    RepliesViewController *repliesCtrl;
    VKViewController *activeUploadCtrl;
    NewsViewController *newsfeedCtrl;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelUpload) name:UploadingViewCancelUploadNotification object:nil];
    
    service = [VKConnectionService shared];
    
    [service.profile addObserver:self forKeyPath:@"hasExtendedMenu" options:0 context:NULL];
    
    profileCtrl = [[ProfileController alloc] initWithProfile:service.profile];
    profileCtrl.delegate = self;
    
    allPhotosCtrl = [AllPhotosController new];
    allPhotosCtrl.delegate = self;
    
    repliesCtrl = [[RepliesViewController alloc] initWithProfile:service.profile];
    repliesCtrl.delegate = self;
    
    newsfeedCtrl = [NewsViewController new];
    newsfeedCtrl.delegate = self;
    
    UINavigationController *profileNavCtrl = [[UINavigationController alloc] initWithRootViewController:profileCtrl];
    UINavigationController *exploreNavCtrl = [[UINavigationController alloc] initWithRootViewController:allPhotosCtrl];
    UINavigationController *repliesNavCtrl = [[UINavigationController alloc] initWithRootViewController:repliesCtrl];
    UINavigationController *homeNavCtrl = [[UINavigationController alloc] initWithRootViewController:newsfeedCtrl];
    
    profileNavCtrl.navigationBarHidden = YES;
    exploreNavCtrl.navigationBarHidden = YES;
    repliesNavCtrl.navigationBarHidden = YES;
    homeNavCtrl.navigationBarHidden = YES;
    
    [profileCtrl view];
    
    controllers =  [NSArray arrayWithObjects:homeNavCtrl, exploreNavCtrl, repliesNavCtrl, profileNavCtrl, nil];
    
    tabBar = [VKTabBar loadFromNIB];
    [tabBar moveBy:CGPointMake(0, self.view.frame.size.height - tabBar.frame.size.height)];
    [self.view addSubview:tabBar];
    
    tabBar.extended = service.profile.hasExtendedMenu;
    
    tabBar.delegate = self;
    tabBar.state = TabBarStateProfile;
    
    choosePhotoView = [ChoosePhotoView loadFromNIB];
    [self.view addSubview:choosePhotoView];
    choosePhotoView.delegate = self;
    
    if (imageToUpload) [self uploadImage:imageToUpload];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"hasExtendedMenu"]) {
        [tabBar setExtended:service.profile.hasExtendedMenu animated:YES];
    }
}

- (void)uploadImage:(ImageToUpload *)image
{
    if (uploadExec) return;
    
    UINavigationController *nav = [controllers objectAtIndex:tabBar.state];
    activeUploadCtrl = (VKViewController*)nav.topViewController;
    
    [activeUploadCtrl showUploading:image.image];
    
    uploadExec = [service uploadPhoto:image];
    uploadExec.delegate = self;
    [uploadExec start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancelUpload
{
    [uploadExec stop];
    uploadExec = nil;
    [activeUploadCtrl cancelUpload:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    [self cancelUpload];
    
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [value objectForKey:@"users"]) {
        Account *acc = [[user objectForKey:@"id"] intValue] == service.profile.accountId ? service.profile : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    
    NSDictionary *photoDict = [value objectForKey:@"photo"];
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:photoDict];
    photo.account = [accounts objectForKey:[photoDict objectForKey:@"user"]];
    
    NSDictionary *replyDict = [photoDict objectForKey:@"reply_to_photo"];
    photo.replyToPhoto = [VKPhoto VKPhotoWithDict:replyDict];
    photo.replyToPhoto.account = [accounts objectForKey:[replyDict objectForKey:@"user"]];
    
    photo.justUploaded = YES;
    [profileCtrl.photosList insert:photo];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    [activeUploadCtrl displayProgress:progress];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    uploadExec = nil;
    [activeUploadCtrl cancelUpload:NO];
}

#pragma mark - VKTabBarDelegate

- (void)VKTabBar:(VKTabBar *)_tabBar didSelectIndex:(NSInteger)index
{    
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
    replyToPhoto = nil;
    [choosePhotoView show:YES withExitButton:NO animated:YES];
}

#pragma mark - ProfileBaseControllerDelegate

- (void)profileBaseControllerDidLogout:(ProfileBaseController *)ctrl
{
    [service logout];
    [self.navigationController popToRootViewControllerTransition:UIViewAnimationTransitionFlipFromRight];
}

- (void)profileBaseControllerWantLoadAvatar:(ProfileBaseController *)ctrl
{
    isAvatar = YES;
    replyToPhoto = nil;
    [choosePhotoView show:YES withExitButton:NO animated:YES];
}

- (void)profileBaseControllerDidBack:(ProfileController *)ctrl
{
    [[controllers objectAtIndex:tabBar.state] popViewControllerAnimated:YES];
}

- (void)profileBaseController:(ProfileController *)ctrl didTapHashTag:(NSString *)hashTag
{
    tabBar.state = TabBarStateExplore;
    [allPhotosCtrl search:hashTag];
}

- (void)profileBaseController:(ProfileBaseController *)ctrl didReplyToPhoto:(VKPhoto *)photo
{
    isAvatar = NO;
    replyToPhoto = photo;
    [choosePhotoView show:YES replyToPhoto:photo animated:YES];
}

- (void)profileBaseController:(ProfileBaseController *)ctrl presenModalViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [self presentModalViewController:controller withPushDirection:kCATransitionFromRight];
}

- (void)profileBaseController:(ProfileBaseController *)ctrl dismissModalViewController:(UIViewController *)controller animated:(BOOL)animated
{
    if (!animated)
        [self dismissModalViewControllerWithPushDirection:kCATransitionFromRight];
    else
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
    photoEditController.replyToPhoto = replyToPhoto;
    
    [self.navigationController pushViewController:photoEditController animated:NO];
}

#pragma mark - PhotoEditControllerDelegate

- (void)photoEditController:(PhotoEditController *)controller didFinishWithImage:(ImageToUpload *)image
{
    [choosePhotoView show:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    [self uploadImage:image];
    
    [super photoEditController:controller didFinishWithImage:image];
}

#pragma mark - ListManagerBaseControllerDelegate

- (void)listBaseController:(ListManagerBaseController *)ctrl didSelectHashTag:(NSString *)tag
{
    tabBar.state = TabBarStateExplore;
    [allPhotosCtrl search:tag];
}

- (void)listBaseController:(ListManagerBaseController *)ctrl didReplyToPhoto:(VKPhoto *)photo
{
    isAvatar = NO;
    replyToPhoto = photo;
    [choosePhotoView show:YES replyToPhoto:photo animated:YES];
}

- (void)listBaseController:(ListManagerBaseController *)ctrl didSelectAccount:(Account *)account animated:(BOOL)animated
{
    if (account.accountId == service.profile.accountId) {
        tabBar.state = TabBarStateProfile;
        return;
    }
    UserAccountController *userCtrl = [[UserAccountController alloc] initWithProfile:(UserProfile*)account];
    userCtrl.delegate = self;
    [ctrl.navigationController pushViewController:userCtrl animated:animated];
}

- (void)listBaseController:(ListManagerBaseController *)ctrl presenModalViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [self presentModalViewController:controller withPushDirection:kCATransitionFromRight];
}

- (void)listBaseController:(ListManagerBaseController *)ctrl dismissModalViewController:(UIViewController *)controller animated:(BOOL)animated
{
    if (!animated)
        [self dismissModalViewControllerWithPushDirection:kCATransitionFromRight];
    else
        [self dismissModalViewControllerWithPushDirection:kCATransitionFromLeft];
}

@end
