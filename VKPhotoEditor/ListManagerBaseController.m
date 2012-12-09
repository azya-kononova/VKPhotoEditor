//
//  ListManagerBaseController.m
//  VKPhotoEditor
//
//  Created by asya on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ListManagerBaseController.h"

#import "UIView+Helpers.h"
#import "UIColor+VKPhotoEditor.h"

@implementation ListManagerBaseController

@synthesize tableHeaderView;
@synthesize noPhotosLabel;
@synthesize activityIndicator;
@synthesize delegate;
@synthesize gridPhotoList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    photosTableView.tableHeaderView = tableHeaderView;
    
    photosTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    photosTableView.pullBackgroundColor = [UIColor blackColor];
    photosTableView.loadBackgroundColor = [UIColor whiteColor];
    photosTableView.pullTextColor = [UIColor blackColor];
    
    ThumbnailPhotoCell *cell = [UITableViewCell loadCellOfType:[ThumbnailPhotoCell class] fromNib:@"ThumbnailPhotoCell" withId:@"ThumbnailPhotoCell"];
    itemsInRow = cell.itemsInRow;
    gridCellHeight = cell.frame.size.height;
}

- (void) viewWillAppear:(BOOL)animated {
    [photosTableView deselectRowAtIndexPath:[photosTableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - actions

- (IBAction)changeGridMode:(UIButton *)sender
{
    sender.selected = !sender.selected;
    isGridMode = !isGridMode;
    [photosTableView reloadData];
}

#pragma mark - Internals

- (NSArray *)getPhotosForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:itemsInRow];
    
    for (int i = 0; i < itemsInRow; i++) {
        int row = itemsInRow * indexPath.row + i;
        if (row < self.gridPhotoList.count) {
            [photos addObject:[self.gridPhotoList objectAtIndex:row]];
        }
    }
    
    return photos;
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    activityIndicator.hidden = YES;
    noPhotosLabel.hidden = photoList.photos.count;
    
    [photosTableView reloadData];
    photosTableView.pullTableIsLoadingMore = NO;
    photosTableView.pullTableIsRefreshing = NO;
    
    //    [tableView setCompleted:searchResultsList.completed];
}

- (void)photoList:(PhotoList *)_photoList didUpdatePhotos:(NSArray *)photos
{
    photosTableView.pullLastRefreshDate = [NSDate date];
    [self reloadPullTable];
}

- (void)photoList:(PhotoList *)_photoList didFailToUpdate:(NSError *)error
{
    [self reloadPullTable];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.backgroundColor = photoList.photos.count ? [UIColor whiteColor] : [UIColor defaultBgColor];
    return isGridMode ? (NSInteger) ceil((double) self.gridPhotoList.count / itemsInRow) : photoList.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) {
        ThumbnailPhotoCell *cell = [ThumbnailPhotoCell dequeOrCreateInTable:photosTableView];
        cell.delegate = self;
        [cell displayPhotos:[self getPhotosForIndexPath:indexPath]];
        return cell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode) return;
    
    VKPhoto *photo = [photoList.photos objectAtIndex:indexPath.row];
    [delegate listBaseController:self didReplyToPhoto:photo];
}


#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [photoList reset];
    [photoList loadMore];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [photoList loadMore];
}

#pragma mark - ThumbnailPhotoCellDelegate

- (void)thumbnailPhotoCell:(ThumbnailPhotoCell *)cell didSelectPhoto:(VKPhoto *)photo
{
    if (!isFastViewerOpen) {
        isFastViewerOpen = YES;
        
        FastViewerController *controller = [[FastViewerController alloc] initWithPhoto:photo];
        controller.delegate = self;
        [delegate listBaseController:self presenModalViewController:controller animated:YES];
    }
}

#pragma mark - FastViewerControllerDelegate

- (void)fastViewerControllerDidFinish:(FastViewerController *)controller
{
    [delegate listBaseController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

- (void)fastViewerController:(FastViewerController *)controller didFinishWithAccount:(Account *)account
{
    [delegate listBaseController:self didSelectAccount:account animated:YES];
    [delegate listBaseController:self dismissModalViewController:controller animated:YES];
    isFastViewerOpen = NO;
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didSelectAccount:(Account *)account
{
    [delegate listBaseController:self didSelectAccount:account animated:YES];
}

- (void)photoCell:(PhotoCell *)photoCell didTapOnPhoto:(VKPhoto *)photo
{
    [delegate listBaseController:self didReplyToPhoto:photo];
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [self.delegate listBaseController:self didSelectHashTag:hashTag];
}

@end
