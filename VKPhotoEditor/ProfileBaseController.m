//
//  ProfileBaseController.m
//  VKPhotoEditor
//
//  Created by Kate on 11/26/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileBaseController.h"
#import "PhotoCell.h"
#import "PhotoView.h"
#import "UIView+Helpers.h"
#import "VKConnectionService.h"
#import "UITableViewCell+NIB.h"
#import "CALayer+Animations.h"
#import "NSArray+Helpers.h"
#import "UIColor+VKPhotoEditor.h"
#import "ThumbnailPhotoCell.h"
#import "FastViewerController.h"
#import "GridModes.h"

#define MENTIONS_GRID_MODE @"MentionsGridMode"
#define FOLLOWERS_GRID_MODE @"FollowersGridMode"
#define PHOTOS_GRID_MODE @"PhotosGridMode"

@interface ProfileBaseController () <PhotoCellDelegate, UIActionSheetDelegate, PhotoListDelegate, TheaterViewDataSource, TheaterViewDelegate, ThumbnailPhotoCellDelegate, FastViewerControllerDelegate>
@end

@implementation ProfileBaseController{
    UserProfile *profile;
    NSInteger selectedPhoto;
    NSMutableDictionary *avatarsForIndexes;
    BOOL avatarsLoaded;
    BOOL infoLoaded;
    UserMenuView *userMenuView;
    BOOL isProfile;
    NSInteger itemsInRow;
    NSInteger gridCellHeight;
    BOOL isFastViewerOpen;
    GridModes *gridModes;
}

@synthesize delegate;
@synthesize noPhotoLabel;
@synthesize loadingView;
@synthesize profile;
@synthesize sourceList;
@synthesize photosList;
@synthesize avatarsList;
@synthesize followersList;
@synthesize mentionsList;
@synthesize profileHeaderView;

- (id)initWithProfile:(UserProfile *)_profile
{
    if (self = [super init]) {
        profile = _profile;
        isProfile = [profile isKindOfClass:UserProfile.class];
        photosList = isProfile ? [[UserPhotoList alloc] initWithPhotos:_profile.lastPhotos] : [UserPhotoList new];
        photosList.delegate = self;
        photosList.account = profile;
        
        avatarsList = [UserPhotoList new];
        avatarsList.delegate = self;
        avatarsList.userPic = YES;
        avatarsList.account = profile;
        
        mentionsList = [MentionList new];
        mentionsList.account = profile;
        mentionsList.delegate = self;
        
        avatarsForIndexes = [NSMutableDictionary new];
        service = [VKConnectionService shared];
        selectedPhoto = -1;
        
        adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
        sourceList = photosList;
        
        gridModes = [GridModes new];
        [self setDefaultGridModes];
        [gridModes setCurrentModeKey:PHOTOS_GRID_MODE];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingView.backgroundColor = [UIColor defaultBgColor];
            
    photosTableView.hidden = YES;
    
    profileHeaderView = [ProfileHeaderView loadFromNIB];
    profileHeaderView.delegate = self;
    profileHeaderView.nameLabel.text = profile.login;
    profileHeaderView.avatarTheaterView.delegate = self;
    profileHeaderView.avatarTheaterView.dataSource = self;
    profileHeaderView.state = ProfileHeaderViewStateHeader;
    [self.view addSubview:profileHeaderView];
    
    userMenuView = [UserMenuView loadFromNIB];
    userMenuView.delegate = self;
    [userMenuView.actionButton setTitle:isProfile ? @"Logout" : @"Block user" forState:UIControlStateNormal];
    [self.view addSubview:userMenuView];
    [userMenuView moveTo:CGPointMake(0, 44)];
    
    photosTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    photosTableView.pullBackgroundColor = [UIColor blackColor];
    photosTableView.loadBackgroundColor = [UIColor clearColor];
    photosTableView.pullTextColor = [UIColor blackColor];
    
    ThumbnailPhotoCell *cell = [UITableViewCell loadCellOfType:[ThumbnailPhotoCell class] fromNib:@"ThumbnailPhotoCell" withId:@"ThumbnailPhotoCell"];
    itemsInRow = cell.itemsInRow;
    gridCellHeight = cell.frame.size.height;
    
    [photosList loadMore];
    [avatarsList loadMore];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressOnTable:)];
    recognizer.minimumPressDuration = 2.0;
    [photosTableView addGestureRecognizer:recognizer];
    
    [adapter start:[service getUser:self.profile.accountId] onSuccess:@selector(exec:didGetUser:) onError:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [delegate profileBaseControllerDidBack:self];
    }
}

- (void)setDefaultGridModes
{
    [gridModes setMode:NO forKey:PHOTOS_GRID_MODE];
    [gridModes setMode:NO forKey:MENTIONS_GRID_MODE];
    [gridModes setMode:YES forKey:FOLLOWERS_GRID_MODE];
}

- (NSArray *)getPhotosForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:itemsInRow];
    
    for (int i = 0; i < itemsInRow; i++) {
        int row = itemsInRow * indexPath.row + i;
        if (row < sourceList.photos.count) {
            [photos addObject:[sourceList.photos objectAtIndex:row]];
        }
    }
    
    return photos;
}

- (void)showContent
{
    if (!(infoLoaded && avatarsLoaded)) return;

    photosTableView.hidden = NO;
    loadingView.hidden = YES;
    
    [profileHeaderView removeFromSuperview];
    
    if (followedByMe) {
        profileHeaderView.state = ProfileHeaderViewStateFollowing;
    } else {
        profileHeaderView.state = avatarsList.photos.count ? ProfileHeaderViewStateFull :  ProfileHeaderViewStateCompact;
    }
        
    photosTableView.tableHeaderView = profileHeaderView;
}

- (void)reloadAvatarList
{
    avatarsForIndexes = nil;
    [avatarsList reset];
    [avatarsList loadMore];
}

#pragma mark - UserMenuViewDelegate

- (void)userMenuViewDidTapAction:(UserMenuView *)view
{
   // Override in subclus
}

- (void)userMenuViewDidCancel:(UserMenuView *)view
{
    profileHeaderView.userMenuButton.selected = NO;
    [userMenuView show:NO];
    photosTableView.scrollEnabled = YES;
}

#pragma mark - ProfileHeaderViewDelegate

- (void)profileHeaderView:(ProfileHeaderView *)view didOpenUserMenu:(BOOL)open
{
    [userMenuView show:open];
    photosTableView.scrollEnabled = !open;
}

- (void)profileHeaderViewDidTapButton:(ProfileHeaderView *)view
{
    // Override in subcluss
}

- (void)profileHeaderView:(ProfileHeaderView *)view didChangeMode:(ProfileHeaderViewMode)mode
{
    switch (mode) {
        case ProfileHeaderViewPhotosMode:
            sourceList = photosList;
            [gridModes setCurrentModeKey:PHOTOS_GRID_MODE];
            break;
        case ProfileHeaderViewFollowersMode:
            sourceList = followersList;
            [gridModes setCurrentModeKey:FOLLOWERS_GRID_MODE];
            break;
        case ProfileHeaderViewsMentiosMode:
            sourceList = mentionsList;
            [gridModes setCurrentModeKey:MENTIONS_GRID_MODE];
            break;
        default:
            break;
    }
    if (sourceList.photos.count == 0) {
        [sourceList reset];
        [sourceList loadMore];
    }
    [photosTableView reloadData];
}

- (void)profileHeaderViewDidBack:(ProfileHeaderView *)view
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)profileHeaderViewDidSwitchGridMode:(ProfileHeaderView *)view
{
    [gridModes switchCurrentModeValue];
    [photosTableView reloadData];
}

#pragma mark - PhotoListDelegate

- (void)reloadPullTable
{
    noPhotoLabel.hidden = sourceList.photos.count;
    [photosTableView reloadData];
    photosTableView.pullTableIsLoadingMore = NO;
    photosTableView.pullTableIsRefreshing = NO;
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    if (photoList == sourceList) {
        photosTableView.pullLastRefreshDate = [NSDate date];
        [self reloadPullTable];
    } else {
        [profileHeaderView.avatarTheaterView reloadData];
        if (!avatarsLoaded) {
            avatarsLoaded = YES;
            [self showContent];
        } 
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error
{
    (photoList ==  sourceList) ? [self reloadPullTable] : [profileHeaderView.avatarTheaterView reloadData];
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [photosList deletePhoto:[ids objectAtIndex:0]];
}

- (void)exec:(VKRequestExecutor*)exec didGetUser:(id)data
{
    NSDictionary *userInfo = [[data objectForKey:@"users_info"] objectAtIndex:0];
    profileHeaderView.photosLabelCount.text = [[userInfo objectForKey:@"photos_count"] stringValue];
    profileHeaderView.mentionsLabelCount.text = [[userInfo objectForKey:@"mentions_count"] stringValue];
    profileHeaderView.followersLabelCount.text = [[userInfo objectForKey:@"followers_count"] stringValue];
    
    NSArray *connections = [userInfo objectForKey:@"connections"];
    followedByMe = [connections find:^BOOL (NSString* string) { return [string isEqualToString:@"following"]; }] != nil;
    
    if (!infoLoaded) {
        infoLoaded = YES;
        [self showContent];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.backgroundColor = sourceList.photos.count ? [UIColor whiteColor] : [UIColor defaultBgColor];
    return gridModes.isGridMode ? (NSInteger) ceil((double) sourceList.photos.count / itemsInRow) : sourceList.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return gridModes.isGridMode ? gridCellHeight : 366;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (gridModes.isGridMode) {
        ThumbnailPhotoCell *cell = [ThumbnailPhotoCell dequeOrCreateInTable:photosTableView];
        cell.delegate = self;
        [cell displayPhotos:[self getPhotosForIndexPath:indexPath]];
        return cell;
    } else {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        VKPhoto *photo = [sourceList.photos objectAtIndex:indexPath.row ];
        [cell displayPhoto:photo canSelectAccount:NO];
        return cell;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && sourceList == photosList) {
        VKPhoto *photo = [sourceList.photos objectAtIndex:selectedPhoto];
        [adapter start:[service deletePhoto:photo.photoId] onSuccess:@selector(exec: didDeletePhoto:) onError:@selector(exec: didFailWithError:)];
    } else if (buttonIndex == 1) {
        VKPhoto *photo = [sourceList.photos objectAtIndex:selectedPhoto];
        if (photo.photo.image) {
            UIImageWriteToSavedPhotosAlbum( photo.photo.image , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    selectedPhoto = -1;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [delegate profileBaseController:self didTapHashTag:hashTag];
}

- (void)photoCell:(PhotoCell *)photoCell didSelectAccount:(Account *)account
{
    
}

- (void)photoCell:(PhotoCell *)photoCell didTapOnPhoto:(VKPhoto *)photo
{
    [delegate profileBaseController:self didReplyToPhoto:photo];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    noPhotoLabel.hidden = YES;
    [sourceList reset];
    [sourceList loadMore];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [sourceList loadMore];
}

- (NSUInteger)numberOfItemsInTheaterView:(TheaterView*)view
{
    return avatarsList.photos.count;
}

- (UIView*)theaterView:(TheaterView*)view viewForItemWithIndex:(NSUInteger)index
{
    PhotoView *viewForIndex =  [avatarsForIndexes objectForKey:[NSNumber numberWithInteger:index]];
    if (!viewForIndex) {
        viewForIndex = [PhotoView loadFromNIB];
        [viewForIndex displayPhoto:[avatarsList.photos objectAtIndex:index]];
        [avatarsForIndexes setObject:viewForIndex forKey:[NSNumber numberWithInteger:index]];
    }
    return viewForIndex;
}

#pragma mark - UILongPressGestureRecognizer

-(void)handleLongPressOnTable:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint point = [recognizer locationInView:photosTableView];
    NSIndexPath *indexPath = [photosTableView indexPathForRowAtPoint:point];
    
    if (indexPath) {
        
        selectedPhoto = (indexPath.row - 1) / 2;
        UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"Delete Image"
                                                     otherButtonTitles:@"Save Image",nil];
        actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actSheet showInView:self.view.superview];
    }
}

#pragma mark - ThumbnailPhotoCellDelegate

- (void)thumbnailPhotoCell:(ThumbnailPhotoCell *)cell didSelectPhoto:(VKPhoto *)photo
{
    if (!isFastViewerOpen) {
        isFastViewerOpen = YES;
        
        FastViewerController *controller = [[FastViewerController alloc] initWithPhoto:photo];
        controller.delegate = self;
        [delegate profileBaseController:self presenModalViewController:controller animated:YES];
    }
}

#pragma mark - FastViewerControllerDelegate

- (void)fastViewerControllerDidFinish:(FastViewerController *)controller
{
    [delegate profileBaseController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

- (void)fastViewerController:(FastViewerController *)controller didFinishWithAccount:(Account *)account {}

@end
