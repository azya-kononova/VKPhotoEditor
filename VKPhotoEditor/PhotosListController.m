//
//  PhotosListControllerController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotosListController.h"
#import "VKTabBar.h"
#import "UIView+NIB.h"
#import "UIView+Helpers.h"
#import "ProfileController.h"
#import "VKRequestExecutor.h"
#import "VKConnectionService.h"
#import "ChoosePhotoView.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345

@interface PhotosListController () <VKTabBarDelegate, VKRequestExecutorDelegate, ChoosePhotoViewDelegate, ProfileControllerDelegate>
@end

@implementation PhotosListController {
    VKTabBar *tabBar;
    NSArray *controllers;
    VKRequestExecutor *exec;
    VKConnectionService *service;
    ChoosePhotoView *choosePhotoView;
}

- (id)initWithImageToUpload:(UIImage *)image
{
    if (self = [super init]) {
        service = [VKConnectionService shared];
        if (!image) return self;
        exec = [service uploadPhoto:image withCaption:@"Test"];
        exec.delegate = self;
        [exec start];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ProfileController *profileCtrl = [[ProfileController alloc] initWithAccount:service.account];
    profileCtrl.delegate = self;
    controllers =  [NSArray arrayWithObjects:profileCtrl, [UIViewController new],nil];
    
    tabBar = [VKTabBar loadFromNIB];
    [tabBar moveBy:CGPointMake(0, self.view.frame.size.height - tabBar.frame.size.height)];
    [self.view addSubview:tabBar];
    
    tabBar.delegate = self;
    tabBar.selectedIndex = 0;
    
    choosePhotoView = [ChoosePhotoView loadFromNIB];
    [self.view addSubview:choosePhotoView];
    choosePhotoView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - ChoosePhotoViewDelegate


- (void)choosePhotoViewDidChooseCameraRoll:(ChoosePhotoView*)view
{
    
}

- (void)choosePhotoViewDidChooseCamera:(ChoosePhotoView*)view
{
    
}

- (void)choosePhotoViewDidCancel:(ChoosePhotoView*)view
{
    [choosePhotoView show:NO animated:YES];
}

- (void)choosePhotoViewDidExit:(ChoosePhotoView*)view
{
    
}

- (void)choosePhotoView:(ChoosePhotoView *)view didChooseImage:(UIImage *)image
{
    
}

@end
