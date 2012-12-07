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
    
    UINavigationController *navCtrl;
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
    
    service = [VKConnectionService shared];
    profileCtrl = [[ProfileController alloc] initWithProfile:service.profile];
    profileCtrl.delegate = self;
    
    allPhotosCtrl = [AllPhotosController new];
    allPhotosCtrl.delegate = self;
    
    repliesCtrl = [[RepliesViewController alloc] initWithProfile:service.profile];
    repliesCtrl.delegate = self;
    
    newsfeedCtrl = [NewsViewController new];
    newsfeedCtrl.delegate = self;
    
    navCtrl = [[[NSBundle mainBundle] loadNibNamed:@"VKNavigationController" owner:self options:nil] objectAtIndex:0];
    //navCtrl.viewControllers = [NSArray arrayWithObject:newsfeedCtrl];
    //navCtrl.viewControllers = [NSArray arrayWithObject:repliesCtrl];
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
    
    if (imageToUpload) [self uploadImage:imageToUpload];
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

#pragma mark VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    uploadExec = nil;
    [activeUploadCtrl cancelUpload:YES];
    
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
    [choosePhotoView show:YES withExitButton:NO animated:YES];
}

- (void)profileBaseControllerDidBack:(ProfileController *)ctrl
{
    tabBar.state = TabBarStateAllPhotos;
}

- (void)profileBaseController:(ProfileController *)ctrl didTapHashTag:(NSString *)hashTag
{
    tabBar.state = TabBarStateAllPhotos;
    [allPhotosCtrl search:hashTag];
}

- (void)profileBaseController:(ProfileBaseController *)ctrl didReplyToPhoto:(VKPhoto *)photo
{
    isAvatar = NO;
    replyToPhoto = photo;
    [choosePhotoView show:YES replyToPhoto:photo animated:YES];
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
    tabBar.state = TabBarStateUnselected;
    UserAccountController *userCtrl = [[UserAccountController alloc] initWithProfile:(UserProfile*)account];
    userCtrl.delegate = self;
    [navCtrl pushViewController:userCtrl animated:animated];
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
