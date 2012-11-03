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

@interface AllPhotosController () <SearchResultsListDelegate, PhotoCellDelegate, PhotoHeaderViewDelegate>
@end

@implementation AllPhotosController {
    SearchResultsList *searchResultsList;
    NSMutableArray *sectionHeaders;
}
@synthesize tableView;
@synthesize tableHeaderView;
@synthesize searchBar;
@synthesize delegate;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:(tableView.contentOffset.y > 0) animated:YES];
}

#pragma mark - PhotosListDelegate

- (void)reloadPullTable
{
    [tableView setCompleted:searchResultsList.completed];
    
    [tableView reloadData];
    
    tableView.pullTableIsLoadingMore = NO;
    tableView.pullTableIsRefreshing = NO;
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
    return searchResultsList.photos.count;
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
    VKPhoto *photo = [searchResultsList.photos objectAtIndex:indexPath.section];
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

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell *)photoCell didTapHashTag:(NSString *)hashTag
{
    [self search:hashTag];
}

- (void)reload
{
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


@end
