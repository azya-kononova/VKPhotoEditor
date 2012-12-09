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
#import "UIView+Helpers.h"
#import "VKConnectionService.h"
#import "UIColor+VKPhotoEditor.h"

@interface AllPhotosController () <UIActionSheetDelegate>
@end

@implementation AllPhotosController {
}

@synthesize searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];

    photoList = [SearchResultsList new];
    photoList.delegate = self;
    
    UIImageView* iview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchHeader.png"]];
    iview.frame = searchBar.bounds;
    [searchBar insertSubview:iview atIndex:1];

    [photoList loadMore];
}


#pragma mark - Internals

- (NSArray *)gridPhotoList
{
    return photoList.photos;
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGridMode)
        return gridCellHeight;
    else {
        VKPhoto *photo = [photoList.photos objectAtIndex:indexPath.row];
        return photo.imageURL ? 366 : 46;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:_tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) return cell;
    
    PhotoCell *photoCell = [PhotoCell dequeOrCreateInTable:photosTableView];
    photoCell.delegate = self;
    VKPhoto *photo = [photoList.photos objectAtIndex:indexPath.row];
    [photoCell displayPhoto:photo];
    
    return photoCell;
}

- (void)setFindModeActive:(BOOL)active
{
    [photosTableView setContentOffset:CGPointZero animated:NO];
    
    if (active == (photosTableView.tableHeaderView == nil)) return;
    
    active ? [self.view addSubview:searchBar] : [self.tableHeaderView addSubview:searchBar];
    CGFloat dy = active ? searchBar.frame.size.height : 0;
    
    photosTableView.frame = CGRectMake(0, dy, self.view.frame.size.width, self.view.frame.size.height - dy);
    [photosTableView beginUpdates];
    photosTableView.tableHeaderView = active ? nil : self.tableHeaderView;
    [photosTableView endUpdates];
    
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
    [self searchPhotos];
    
    for (UIView *possibleButton in searchBar.subviews) {
        if ([possibleButton isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

- (void)reload
{
    self.noPhotosLabel.hidden = YES;
    [photoList reset];
    [photosTableView reloadData];
    [photoList loadMore];
}

#pragma mark - PhotoCellDelegate

#pragma mark - UISearchBarDelegate

- (void)searchPhotos
{
    ((SearchResultsList *)photoList).query = searchBar.text;
    [self reload];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    [self setFindModeActive:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    _searchBar.text = nil;
    [self searchPhotos];
    [self setFindModeActive:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar;
{
    [searchBar resignFirstResponder];
    [self searchPhotos];
    
    for (UIView *possibleButton in searchBar.subviews) {
        if ([possibleButton isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

@end
