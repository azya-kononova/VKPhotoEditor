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

@interface ProfileController () <UITableViewDataSource, PullTableViewDelegate, PhotosListDelegate, UIActionSheetDelegate, PhotoHeaderViewDelegate, PhotoCellDelegate>
@end

@implementation ProfileController {
    UserProfile *account;
    UserPhotosList *photosList;
    NSMutableArray *sectionHeaders;
    RequestExecutorDelegateAdapter *adapter;
    NSInteger offset;
    VKConnectionService *service;
    NSInteger selectedPhoto;
    BOOL isProfile;
}
@synthesize nameLabel;
@synthesize delegate;
@synthesize tableView;
@synthesize titleView;
@synthesize avatarButton;
@synthesize addAvatarView;

- (id)initWithAccount:(UserProfile *)_account
{
    if (self = [super init]) {
        account = _account;
        isProfile = [account isKindOfClass:UserProfile.class];
        photosList = (isProfile) ? [[UserPhotosList alloc] initWithPhotos:account.lastPhotos] : [UserPhotosList new];
        photosList.delegate = self;
        sectionHeaders = [NSMutableArray new];
        service = [VKConnectionService shared];
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
        selectedPhoto = -1;
    }
    return self;
}               

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewDidLoad];
    if (isProfile) {
        nameLabel.text = account.login;
        self.navigationItem.titleView = titleView;
        addAvatarView.hidden = account.avatarUrl != nil;
        [nameLabel moveTo:CGPointMake(nameLabel.frame.origin.x, account.avatarUrl ? 12 : 3)];
        [avatarButton displayImage:account.avatar];
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

- (void)uploadImage:(UIImage *)image
{
    [adapter start:[service uploadPhoto:image withCaption:@""] onSuccess:@selector(exec:didUploadPhoto:) onError:@selector(exec:didFailWithError:)];
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
    if (!photosList.completed) [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
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

#pragma mark - Request Handler

//TODO: show result with row animation???

- (void)exec:(VKRequestExecutor*)exec didUploadPhoto:(id)value
{
    VKPhoto *photo = [VKPhoto VKPhotoWithDict:[value objectForKey:@"photo"]];
    photo.account = [Account accountWithDict:[[value objectForKey:@"users"] objectAtIndex:0]];
    photo.justUploaded = YES;
    [photosList insert:photo];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}

- (void)exec:(VKRequestExecutor*)exec didFailWithError:(NSError*)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
