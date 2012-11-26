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
#import "UserPhotosList.h"
#import "VKConnectionService.h"
#import "VKRequestExecutor.h"
#import "UIView+Helpers.h"
#import "CALayer+Animations.h"
#import "PhotoHeaderCell.h"
#import "AvatarView.h"

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
        [self.profile addObserver:self forKeyPath:@"avatarUrl" options:0 context:NULL];
        service = [VKConnectionService shared];
    }
    return self;
}

- (void)dealloc
{
    [self.profile removeObserver:self forKeyPath:@"avatarUrl"];
}

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    uploadingView.superview.layer.cornerRadius = 6;
    uploadingImageView.layer.cornerRadius = 17.5;
    uploadWidth = uploadingView.superview.frame.size.width;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"avatarUrl"]) {
        [self reloadAvatar];
    }
}

- (void)reloadAvatar
{
    [self showAvatar:self.profile.avatar animated:NO];
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
    
    uploadPhotoExec = [service uploadPhoto:image.image withCaption:image.caption];
    uploadPhotoExec.delegate = self;
    [uploadPhotoExec start];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - actions

- (IBAction)openProfile
{
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    [self cancelUpload];
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:[value objectForKey:@"photo"]];
    photo.account = [Account accountWithDict:[[value objectForKey:@"users"] objectAtIndex:0]];
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
