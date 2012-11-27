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
#import "PhotoHeaderCell.h"

@interface AllPhotosController () <PhotoListDelegate, PhotoCellDelegate, PhotoHeaderViewDelegate, UIActionSheetDelegate, GridModeButtonDelegate, ThumbnailPhotoCellDelegate, FastViewerControllerDelegate>
@end

@implementation AllPhotosController {
    SearchResultsList *searchResultsList;
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
    
    tableView.tableHeaderView = tableHeaderView;
    
    UIImageView* iview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchHeader.png"]];
    iview.frame = searchBar.bounds;
    [searchBar insertSubview:iview atIndex:1];
    
    tableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    tableView.pullBackgroundColor = [UIColor blackColor];
    tableView.loadBackgroundColor = [UIColor whiteColor];
    tableView.pullTextColor = [UIColor blackColor];
    
    [searchResultsList loadNextPageFor:nil];
    
    GridModeButton *gridButton = [GridModeButton loadFromNIB];
    gridButton.delegate = self;
    [gridButton moveTo:CGPointMake(280, 5)];
    [tableHeaderView addSubview:gridButton];
    
    selectedPhoto = -1;
    adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
    
    ThumbnailPhotoCell *cell = [UITableViewCell loadCellOfType:[ThumbnailPhotoCell class] fromNib:@"ThumbnailPhotoCell" withId:@"ThumbnailPhotoCell"];
    itemsInRow = cell.itemsInRow;
    gridCellHeight = cell.frame.size.height;
}

- (void) viewWillAppear:(BOOL)animated {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
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

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    tableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error
{
      [self reloadPullTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return isGridMode ? (NSInteger) ceil((double) searchResultsList.photos.count / itemsInRow) : searchResultsList.photos.count * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TODO: handle situations when users find
    CGFloat height;
    
    if (isGridMode)
        height = gridCellHeight;
    else
        height = (indexPath.row % 2 == 0) ? 46 : 320;
    
    return height;
}

- (UITableViewCell*)photoOrHeaderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        PhotoHeaderCell *cell = [PhotoHeaderCell dequeOrCreateInTable:tableView];
        [cell displayPhoto:[searchResultsList.photos objectAtIndex:indexPath.row / 2]];
        return cell;
    } else {
        PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
        cell.delegate = self;
        VKPhoto *photo = [searchResultsList.photos objectAtIndex:(indexPath.row - 1) / 2];
        [cell displayPhoto:photo];
        return cell;
    }
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
        return [self photoOrHeaderForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) return;
    
    selectedPhoto = indexPath.section;
    
    if (indexPath.row % 2 == 0) {
        [delegate allPhotosController:self didSelectAccount:[[searchResultsList.photos objectAtIndex:indexPath.row/2] account]];
        return;
    }
    
    if (![self isProfilePhoto]) return;
    
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Delete Image"
                                                 otherButtonTitles:@"Save Image",nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showInView:self.view.superview];
}

- (void)setFindModeActive:(BOOL)active
{
    [tableView setContentOffset:CGPointZero animated:NO];
    
    if (active == (tableView.tableHeaderView == nil)) return;
    
    active ? [self.view addSubview:searchBar] : [tableHeaderView addSubview:searchBar];
    CGFloat dy = active ? searchBar.frame.size.height : 0;
    
    tableView.frame = CGRectMake(0, dy, self.view.frame.size.width, self.view.frame.size.height - dy);
    [tableView beginUpdates];
    tableView.tableHeaderView = active ? nil : tableHeaderView;
    [tableView endUpdates];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        [searchBar moveTo:CGPointMake(0, active ? 0 : 44)];
    } completion:^(BOOL finished) {
    }];

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
