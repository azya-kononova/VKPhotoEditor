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

@interface ProfileController () <UITableViewDataSource, PullTableViewDelegate, PhotosListDelegate, UIActionSheetDelegate, PhotoCellDelegate, VKRequestExecutorDelegate>
@end

@implementation ProfileController {
    UserProfile *profile;
    UserPhotosList *photosList;
    UserPhotosList *avatarsList;
    RequestExecutorDelegateAdapter *adapter;
    VKRequestExecutor *uploadPhotoExec;
    NSInteger offset;
    VKConnectionService *service;
    NSInteger selectedPhoto;
    CGFloat uploadWidth;
    BOOL isUploading;
    NSMutableDictionary *avatarsForIndexes;
}

@synthesize nameLabel;
@synthesize delegate;
@synthesize tableView;
@synthesize headerView;
@synthesize setPhotoButton;
@synthesize avatarTheaterView;

@synthesize uploadingContainerView;
@synthesize uploadingView;
@synthesize uploadingImageView;
@synthesize uploadInfoLabel;
@synthesize noPhotoLabel;
@synthesize savingIndicator;
@synthesize headerTopView;
@synthesize headerBottomView;
@synthesize noAvatarImageView;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super init]) {
        profile = _profile;
        photosList = [[UserPhotosList alloc] initWithPhotos:profile.lastPhotos];
        avatarsList = [UserPhotosList new];
        [profile addObserver:self forKeyPath:@"avatarUrl" options:0 context:NULL];
        photosList.delegate = self;
        avatarsList.delegate = self;
        service = [VKConnectionService shared];
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
        selectedPhoto = -1;
        avatarsForIndexes = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [profile removeObserver:self forKeyPath:@"avatarUrl"];
}

- (void)showAvatar:(RemoteImage*)avatar animated:(BOOL)animated;
{
    BOOL show = YES;
    avatarTheaterView.hidden = !show;
    [tableView beginUpdates];
    CGFloat newHeight = headerTopView.frame.size.height + headerBottomView.frame.size.height + (show ? avatarTheaterView.frame.size.height : noAvatarImageView.frame.size.height);
    if (animated) 
        [UIView animateWithDuration:0.8 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
            [headerView resizeTo:CGSizeMake(headerView.frame.size.height, newHeight)];
        } completion:^(BOOL finished) {}];
    else
        [headerView resizeTo:CGSizeMake(headerView.frame.size.height, newHeight)];
    [tableView endUpdates];
    tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    [self showAvatar:profile.avatar animated:NO];
    
    setPhotoButton.bgImagecaps = CGSizeMake(23, 0);
    
    uploadingView.superview.layer.cornerRadius = 6;
    uploadingImageView.layer.cornerRadius = 17.5;
    uploadWidth = uploadingView.superview.frame.size.width;
    
    nameLabel.text = profile.login;
    
    tableView.tableHeaderView = headerView;
    tableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    tableView.pullBackgroundColor = [UIColor blackColor];
    tableView.pullTextColor = [UIColor blackColor];
    
    tableView.pullTableIsRefreshing = YES;
    [photosList loadNextPageFor:profile.accountId];
    [avatarsList loadNextPageFor:profile.accountId userPic:YES];
    [avatarTheaterView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [delegate profileControllerDidBack:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"avatarUrl"]) {
        [self reloadAvatar];
    }
}

- (void)reloadAvatar
{
    [self showAvatar:profile.avatar animated:NO];
}

- (void)showUploading:(UIImage*)image
{
    BOOL show = image != nil;
    
    if (show) uploadInfoLabel.text = nil;
   
    isUploading = show;
    if (show) [tableView reloadData];
    uploadingImageView.image = image;
    [uploadingView resizeTo:CGSizeMake(0, uploadingView.frame.size.height)];
    if (!show && tableView.contentOffset.y > tableView.tableHeaderView.frame.size.height) [tableView setContentOffset:CGPointMake(0, tableView.tableHeaderView.frame.size.height) animated:YES];
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
    [delegate profileControllerDidOpenProfile:self];
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    noPhotoLabel.hidden = photosList.photos.count;
    [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
    
//    [tableView setCompleted:photosList.completed];
}

- (void)photosList:(UserPhotosList *)_photosList didUpdatePhotos:(NSArray *)photos
{
    if (_photosList == photosList) {
        tableView.pullLastRefreshDate = [NSDate date];
        [self reloadPullTable];
    } else {
        [avatarTheaterView reloadData];
    }
}

- (void)photosList:(UserPhotosList *)_photosList didFailToUpdate:(NSError *)error
{
    (_photosList ==  photosList) ? [self reloadPullTable] :  [avatarTheaterView reloadData];
}

- (void)cancelUpload
{
    uploadPhotoExec = nil;
    [self showUploading:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    [self cancelUpload];
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:[value objectForKey:@"photo"]];
    photo.account = [Account accountWithDict:[[value objectForKey:@"users"] objectAtIndex:0]];
    photo.justUploaded = YES;
    [photosList insert:photo];
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

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return photosList.photos.count * 2;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2 == 0) ? 46 : 320;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        PhotoHeaderCell *cell = [PhotoHeaderCell dequeOrCreateInTable:tableView];
        [cell displayPhoto:[photosList.photos objectAtIndex:indexPath.row / 2]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType =  UITableViewCellAccessoryNone;
        return cell;
    } else {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        VKPhoto *photo = [photosList.photos objectAtIndex:(indexPath.row - 1) / 2];
        [cell displayPhoto:photo];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) return;
    
    selectedPhoto = indexPath.section;
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Delete Image"
                                                 otherButtonTitles:@"Save Image",nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showInView:self.view.superview];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if (buttonIndex == 0) {
        VKPhoto *photo = [photosList.photos objectAtIndex:selectedPhoto];
        [adapter start:[service deletePhoto:photo.photoId] onSuccess:@selector(exec: didDeletePhoto:) onError:@selector(exec: didFailWithError:)];
    } else if (buttonIndex == 1) {
        VKPhoto *photo = [photosList.photos objectAtIndex:selectedPhoto];
        if (photo.photo.image) {
            [savingIndicator startAnimating];
            UIImageWriteToSavedPhotosAlbum( photo.photo.image , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    selectedPhoto = -1;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [savingIndicator stopAnimating];
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [delegate profileController:self didTapHashTag:hashTag];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    noPhotoLabel.hidden = YES;
    [photosList reset];
    [photosList loadNextPageFor:profile.accountId];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [photosList loadNextPageFor:profile.accountId];
}

- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view
{
    return avatarsList.photos.count;
}

- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index
{
    AvatarView *viewForIndex =  [avatarsForIndexes objectForKey:[NSNumber numberWithInteger:index]];
    if (!viewForIndex) {
        viewForIndex = [AvatarView loadFromNIB];
        [viewForIndex displayPhoto:[avatarsList.photos objectAtIndex:index]];
        [avatarsForIndexes setObject:viewForIndex forKey:[NSNumber numberWithInteger:index]];
    }
    return viewForIndex;
}

@end
