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

@interface ProfileController () <UITableViewDataSource, PullTableViewDelegate, PhotosListDelegate, UIActionSheetDelegate, PhotoHeaderViewDelegate, PhotoCellDelegate, VKRequestExecutorDelegate>
@end

@implementation ProfileController {
    UserProfile *account;
    UserPhotosList *photosList;
    NSMutableArray *sectionHeaders;
    RequestExecutorDelegateAdapter *adapter;
    VKRequestExecutor *uploadPhotoExec;
    NSInteger offset;
    VKConnectionService *service;
    NSInteger selectedPhoto;
    BOOL isProfile;
    CGFloat uploadWidth;
}
@synthesize nameLabel;
@synthesize delegate;
@synthesize tableView;
@synthesize titleView;
@synthesize avatarButton;
@synthesize addAvatarView;

@synthesize uploadingContainerView;
@synthesize uploadingView;
@synthesize uploadingImageView;
@synthesize uploadInfoLabel;

- (id)initWithAccount:(UserProfile *)_account
{
    if (self = [super init]) {
        account = _account;
        isProfile = [account isKindOfClass:UserProfile.class];
        photosList = (isProfile) ? [[UserPhotosList alloc] initWithPhotos:account.lastPhotos] : [UserPhotosList new];
        if (isProfile) {
            [account addObserver:self forKeyPath:@"avatarUrl" options:0 context:NULL];
        }
        photosList.delegate = self;
        sectionHeaders = [NSMutableArray new];
        service = [VKConnectionService shared];
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
        selectedPhoto = -1;
    }
    return self;
}

- (void)dealloc
{
    if (isProfile) [account removeObserver:self forKeyPath:@"avatarUrl"];
}

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    uploadingView.superview.layer.cornerRadius = 6;
    uploadingImageView.layer.cornerRadius = 8;
    uploadWidth = uploadingView.superview.frame.size.width;
    
    if (isProfile) {
        nameLabel.text = account.login;
        self.navigationItem.titleView = titleView;
        [self reloadAvatar];
    } else {
        self.navigationItem.title = account.login;
    }
    
    tableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    tableView.pullBackgroundColor = [UIColor lightGrayColor];
    tableView.pullTextColor = [UIColor blackColor];
    
    tableView.pullTableIsRefreshing = YES;
    [photosList loadNextPageFor:account.accountId];
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
    BOOL hasAvatar = account.avatarUrl != nil;
    addAvatarView.hidden = hasAvatar;
    [nameLabel moveTo:CGPointMake(nameLabel.frame.origin.x, hasAvatar ? 12 : 3)];
    [avatarButton displayImage:account.avatar];
}

- (void)showUploading:(UIImage*)image
{
    BOOL show = image != nil;
    
    if (show) uploadInfoLabel.text = nil;
    
    [uploadingContainerView.layer fade].duration = 0.8;
    uploadingContainerView.hidden = !show;
    [UIView animateWithDuration:0.8 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
         [tableView moveTo:CGPointMake(0, show ? uploadingContainerView.frame.size.height : 0)];
    } completion:^(BOOL finished) {}];
   
    uploadingImageView.image = image;
    
    [uploadingView resizeTo:CGSizeMake(0, uploadingView.frame.size.height)];
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
    [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
    
//    [tableView setCompleted:photosList.completed];
}

- (void)photosList:(UserPhotosList *)_photosList didUpdatePhotos:(NSArray *)photos
{
    tableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
}

- (void)photosList:(UserPhotosList *)photosList didFailToUpdate:(NSError *)error
{
    [self reloadPullTable];
}

- (void)cancelUpload
{
    uploadPhotoExec = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(showUploading:) withObject:nil afterDelay:1];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:[value objectForKey:@"photo"]];
    photo.account = [Account accountWithDict:[[value objectForKey:@"users"] objectAtIndex:0]];
    photo.justUploaded = YES;
    [photosList insert:photo];
    uploadInfoLabel.text = @"Done!";
    [self cancelUpload];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    uploadInfoLabel.text = @"Failed";
    [self cancelUpload];
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    [uploadingView resizeTo:CGSizeMake(uploadWidth * progress, uploadingView.frame.size.height)];
    NSLog(@"Did upload %f", progress);
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return photosList.photos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
    cell.delegate = self;
    VKPhoto *photo = [photosList.photos objectAtIndex:indexPath.section];
    [cell displayPhoto:photo];
    return cell;
}

- (PhotoHeaderView *)dequeueHeader
{
    for (PhotoHeaderView *view in sectionHeaders) {
        if (!view.superview) return view;
    }
    return nil;
}

- (NSString *)sectionHeaderTitleForSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{    
    PhotoHeaderView* headerView = [self dequeueHeader];
    if (!headerView)
    {
        headerView = [PhotoHeaderView loadFromNIB];
        headerView.delegate = self;
        [sectionHeaders addObject:headerView];
    }
    [headerView displayPhoto:[photosList.photos objectAtIndex:section]];
    return headerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    } else {
        selectedPhoto = -1;
    }
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [delegate profileController:self didTapHashTag:hashTag];
}

#pragma mark - PhotoHeaderViewDelegate

- (void)photoHeaderView:(PhotoHeaderView *)view didSelectAccount:(Account *)_account
{
    NSLog(@"Account id: %d", _account.accountId);
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [photosList reset];
    [photosList loadNextPageFor:account.accountId];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [photosList loadNextPageFor:account.accountId];
}


@end
