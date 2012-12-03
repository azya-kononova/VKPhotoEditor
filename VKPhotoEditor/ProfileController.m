//
//  ProfileController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileController.h"
#import "PhotoCell.h"
#import "PhotoHeaderView.h"
#import "VKPhoto.h"
#import "RequestExecutorDelegateAdapter.h"
#import "UserPhotoList.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "UIView+Helpers.h"
#import "CALayer+Animations.h"
#import "PhotoView.h"

@interface ProfileController () <VKRequestExecutorDelegate>
@end

@implementation ProfileController {
    VKRequestExecutor *uploadPhotoExec;
    VKConnectionService *service;
    CGFloat uploadWidth;
    BOOL isUploading;
}

@synthesize uploadingContainerView;
@synthesize uploadingView;
@synthesize uploadingImageView;
@synthesize uploadInfoLabel;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super initWithProfile:_profile]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAvatarList) name:VKRequestDidUpdateAvatarNotification object:nil];
        service = [VKConnectionService shared];
    }
    return self;
}

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    self.profileHeaderView.backButton.hidden = YES;
    
    uploadingView.superview.layer.cornerRadius = 6;
    uploadingImageView.layer.cornerRadius = 17.5;
    uploadWidth = uploadingView.superview.frame.size.width;
}

- (void)showUploading:(UIImage*)image
{
    BOOL show = image != nil;
    
    if (show) uploadInfoLabel.text = nil;
   
    isUploading = show;
    if (show) [self.photosTableView reloadData];
    uploadingImageView.image = image;
    [uploadingView resizeTo:CGSizeMake(0, uploadingView.frame.size.height)];
    if (!show && self.photosTableView.contentOffset.y > self.photosTableView.tableHeaderView.frame.size.height) [self.photosTableView setContentOffset:CGPointMake(0, self.photosTableView.tableHeaderView.frame.size.height) animated:YES];
}

- (void)uploadImage:(ImageToUpload *)image
{
    if (uploadPhotoExec) return;
    
    [self showUploading:image.image];
    
    uploadPhotoExec = [service uploadPhoto:image];
    uploadPhotoExec.delegate = self;
    [uploadPhotoExec start];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - profileHeaderViewDelegate

- (void)profileHeaderViewDidTapButton:(ProfileHeaderView *)view
{
    VKPhoto *selectedPhoto = [self.avatarsList.photos objectAtIndex:self.profileHeaderView.avatarTheaterView.displayedItemIndex];
    VKRequestExecutor *exec = [service updateUserPic:selectedPhoto.photoId];
    [adapter start:exec onSuccess:@selector(VKRequestExecutor:didUpdatePhoto:) onError:nil];
}

#pragma mark - actions

- (IBAction)openProfile
{
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didUpdatePhoto:(id)value
{
    [self.photosTableView reloadData];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    [self cancelUpload];
    
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [value objectForKey:@"users"]) {
        Account *acc = [[user objectForKey:@"id"] intValue] == self.profile.accountId ? self.profile : [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }
    
    NSDictionary *photoDict = [value objectForKey:@"photo"];
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:photoDict];
    photo.account = [accounts objectForKey:[photoDict objectForKey:@"user"]];
    
    NSDictionary *replyDict = [photoDict objectForKey:@"reply_to_photo"];
    photo.replyToPhoto = [VKPhoto VKPhotoWithDict:replyDict];
    photo.replyToPhoto.account = [accounts objectForKey:[replyDict objectForKey:@"user"]];
    
    photo.justUploaded = YES;
    [self.photosList insert:photo];
    uploadInfoLabel.text = @"Done!";
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    uploadInfoLabel.text = @"Failed";
    [self cancelUpload];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    [uploadingView resizeTo:CGSizeMake(uploadWidth * progress, uploadingView.frame.size.height)];
}

- (void)cancelUpload
{
    uploadPhotoExec = nil;
    [self showUploading:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [self.photosList deletePhoto:[ids objectAtIndex:0]];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section
{
    return isUploading ? uploadingContainerView.frame.size.height : 0;
}

- (UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    return isUploading ? uploadingContainerView : nil;
}

@end
