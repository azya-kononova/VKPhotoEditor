//
//  AllPhotosController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "AllPhotosController.h"
#import "SearchResultsList.h"
#import "PhotoCell.h"
#import "PhotoHeaderView.h"
#import "UIView+Helpers.h"
#import "RequestExecutorDelegateAdapter.h"
#import "VKConnectionService.h"
#import "ThumbnailPhotoCell.h"
#import "GridModeButton.h"
#import "UIColor+VKPhotoEditor.h"
#import "FastViewerController.h"

@interface AllPhotosController () <SearchResultsListDelegate, PhotoCellDelegate, PhotoHeaderViewDelegate, UIActionSheetDelegate, GridModeButtonDelegate, ThumbnailPhotoCellDelegate, FastViewerControllerDelegate>
@end

@implementation AllPhotosController {
    SearchResultsList *searchResultsList;
    NSMutableArray *sectionHeaders;
    NSInteger selectedPhoto;
    RequestExecutorDelegateAdapter *adapter;
    
    BOOL isGridMode;
    BOOL isFastViewerOpen;
    NSInteger itemsInRow;
    NSInteger gridCellHeight;
}
@synthesize tableView;
@synthesize tableHeaderView;
@synthesize searchBar;
@synthesize delegate;
@synthesize noPhotosLabel;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchResultsList = [SearchResultsList new];
    searchResultsList.delegate = self;
    sectionHeaders = [NSMutableArray new];
    
    tableView.tableHeaderView = tableHeaderView;
    
    UIImageView* iview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchHeader.png"]];
    iview.frame = searchBar.bounds;
    [searchBar insertSubview:iview atIndex:1];
    
    tableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    tableView.pullBackgroundColor = [UIColor lightGrayColor];
    tableView.pullTextColor = [UIColor blackColor];
    
    tableView.pullTableIsRefreshing = YES;
    [searchResultsList loadNextPageFor:nil];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = @"All photos";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    GridModeButton *gridButton = [GridModeButton loadFromNIB];
    gridButton.delegate = self;
    UIBarButtonItem *gridItem = [[UIBarButtonItem alloc] initWithCustomView:gridButton];
    self.navigationItem.rightBarButtonItem = gridItem;
    
    selectedPhoto = -1;
    adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
    
    ThumbnailPhotoCell *cell = [UITableViewCell loadCellOfType:[ThumbnailPhotoCell class] fromNib:@"ThumbnailPhotoCell" withId:@"ThumbnailPhotoCell"];
    itemsInRow = cell.itemsInRow;
    gridCellHeight = cell.frame.size.height;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:(tableView.contentOffset.y > 0) animated:YES];
}

#pragma mark - Internals

- (NSArray *)getPhotosForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:itemsInRow];
    
    for (int i = 0; i < itemsInRow; i++) {
        int row = itemsInRow * indexPath.row + i;
        if (row < searchResultsList.photos.count) {
            [photos addObject:[searchResultsList.photos objectAtIndex:row]];
        }
    }
    
    return photos;
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    activityIndicator.hidden = YES;
    noPhotosLabel.hidden = searchResultsList.photos.count;
    
    [tableView reloadData];
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
    
//    [tableView setCompleted:searchResultsList.completed];
}

- (void)searchResultsList:(SearchResultsList *)photosList didUpdatePhotos:(NSArray *)photos user:(Account *)user
{
     tableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
}

- (void)searchResultsList:(SearchResultsList *)photosList didFailToUpdate:(NSError *)error
{
    [self reloadPullTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return isGridMode ? 1 : searchResultsList.photos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return isGridMode ? (NSInteger) ceil((double) searchResultsList.photos.count / itemsInRow) : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VKPhoto *photo = [searchResultsList.photos objectAtIndex:indexPath.section];
    
    if (photo.imageURL) {
        return isGridMode ? gridCellHeight : 320;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) {
        ThumbnailPhotoCell *cell = [ThumbnailPhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        cell.searchString = searchBar.text;
        [cell displayPhotos:[self getPhotosForIndexPath:indexPath]];
        
        return cell;
    } else {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        cell.searchString = searchBar.text;
        VKPhoto *photo = [searchResultsList.photos objectAtIndex:indexPath.section];
        [cell displayPhoto:photo];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) return;
    
    selectedPhoto = indexPath.section;
    
    if (![self isProfilePhoto]) return;
    
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Delete Image"
                                                 otherButtonTitles:@"Save Image",nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showInView:self.view.superview];
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
    return isGridMode ? 0 : 46.0;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (isGridMode) return nil;
    
    PhotoHeaderView* headerView = [self dequeueHeader];
    if (!headerView)
    {
        headerView = [PhotoHeaderView loadFromNIB];
        headerView.delegate = self;
        [sectionHeaders addObject:headerView];
    }
    [headerView displayPhoto:[searchResultsList.photos objectAtIndex:section]];
    return headerView;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    BOOL findModeActive = !tableView.tableHeaderView;
    if (!findModeActive) [self.navigationController setNavigationBarHidden:(scrollView.contentOffset.y > 0) animated:NO];
}

- (void)setFindModeActive:(BOOL)active
{
    [tableView setContentOffset:CGPointZero animated:NO];
    
    if (active == (tableView.tableHeaderView == nil)) return;
    
    if (active) [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    active ? [self.view addSubview:searchBar] : [tableHeaderView addSubview:searchBar];
    CGFloat dy = active ? searchBar.frame.size.height : 0;
    tableView.frame = CGRectMake(0, dy, self.view.frame.size.width, self.view.frame.size.height - dy);

     if (!active) [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [tableView beginUpdates];
    tableView.tableHeaderView = active ? nil : tableHeaderView;
    [tableView endUpdates];
    
    [searchBar setShowsCancelButton:active animated:YES];
}

- (void)search:(NSString *)query
{
    [self setFindModeActive:YES];
    searchBar.text = query;
    
    [self reload];
    
    for (UIView *possibleButton in searchBar.subviews) {
        if ([possibleButton isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

- (BOOL)isProfilePhoto
{
    Account *account = [[searchResultsList.photos objectAtIndex:selectedPhoto] account];
    return account.accountId == [VKConnectionService shared].profile.accountId;
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [self search:hashTag];
}

- (void)reload
{
    noPhotosLabel.hidden = YES;
    tableView.pullTableIsRefreshing = YES;
    [searchResultsList reset];
    [tableView reloadData];
    [searchResultsList loadNextPageFor:searchBar.text];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    [self setFindModeActive:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    _searchBar.text = nil;
    [self reload];
    [self setFindModeActive:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar;
{
    [searchBar resignFirstResponder];
    [self reload];
    
    for (UIView *possibleButton in searchBar.subviews) {
        if ([possibleButton isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

#pragma mark - PhotoHeaderViewDelegate

- (void)photoHeaderView:(PhotoHeaderView *)view didSelectAccount:(Account *)_account
{
    [delegate allPhotosController:self didSelectAccount:_account];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [searchResultsList reset];
    [searchResultsList loadNextPageFor:searchBar.text];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [searchResultsList loadNextPageFor:searchBar.text];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        VKPhoto *photo = [searchResultsList.photos objectAtIndex:selectedPhoto];
        [adapter start:[[VKConnectionService shared] deletePhoto:photo.photoId] onSuccess:@selector(exec: didDeletePhoto:) onError:@selector(exec: didFailWithError:)];
    } else if (buttonIndex == 1) {
        VKPhoto *photo = [searchResultsList.photos objectAtIndex:selectedPhoto];
        if (photo.photo.image) {
            UIImageWriteToSavedPhotosAlbum(photo.photo.image , self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    selectedPhoto = -1;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
}

#pragma mark - Request Handler

- (void)exec:(VKRequestExecutor*)exec didDeletePhoto:(id)ids
{
    if ([ids count]) [searchResultsList deletePhoto:[ids objectAtIndex:0]];
}

#pragma mark - GridModeButtonDelegate

- (void)gridModeButtonDidSwitchMode:(GridModeButton *)gridButton
{
    isGridMode = !isGridMode;
    tableView.backgroundColor = isGridMode ? [UIColor defaultBgColor] : [UIColor whiteColor];
    [tableView reloadData];
}

#pragma mark - ThumbnailPhotoCellDelegate

- (void)thumbnailPhotoCell:(ThumbnailPhotoCell *)cell didSelectPhoto:(VKPhoto *)photo
{
    if (!isFastViewerOpen) {
        isFastViewerOpen = YES;
        
        FastViewerController *controller = [[FastViewerController alloc] initWithPhoto:photo];
        controller.delegate = self;
        [delegate allPhotosController:self presenModalViewController:controller animated:YES];
    }
}

#pragma mark - FastViewerControllerDelegate

- (void)fastViewerControllerDidFinish:(FastViewerController *)controller
{
    [delegate allPhotosController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

@end
