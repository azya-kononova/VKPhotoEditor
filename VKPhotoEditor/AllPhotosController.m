//
//  AllPhotosController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "AllPhotosController.h"
#import "SearchResultsList.h"
#import "LoadingCell.h"
#import "PhotoCell.h"
#import "PhotoHeaderView.h"
#import "UIView+Helpers.h"

@interface AllPhotosController () <SearchResultsListDelegate>
@end

@implementation AllPhotosController {
    SearchResultsList *searchResultsList;
    NSMutableArray *sectionHeaders;
}
@synthesize tableView;
@synthesize tableHeaderView;
@synthesize searchBar;

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
}

#pragma mark - PhotosListDelegate

- (void)searchResultsList:(SearchResultsList *)photosList didUpdatePhotos:(NSArray *)photos user:(Account *)user
{
    [tableView reloadData];
}

- (void)searchResultsList:(SearchResultsList *)photosList didFailToUpdate:(NSError *)error
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return searchResultsList.photos.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == searchResultsList.photos.count) {
        return searchResultsList.completed ? 0 : 1;
    }
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == searchResultsList.photos.count ? 41 : 320;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == searchResultsList.photos.count) {
        [searchResultsList loadNextPageFor:searchBar.text];
        return [LoadingCell dequeOrCreateInTable:tableView];
    }
    PhotoCell *cell = [PhotoCell dequeOrCreateInTable:tableView];
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
    return (section == searchResultsList.photos.count) ? 0 : 46.0;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == searchResultsList.photos.count) return nil;
    
    PhotoHeaderView* headerView = [self dequeueHeader];
    if (!headerView)
    {
        headerView = [PhotoHeaderView loadFromNIB];
        [sectionHeaders addObject:headerView];
    }
    [headerView displayPhoto:[searchResultsList.photos objectAtIndex:section]];
    return headerView;
}

- (void)setFindModeActive:(BOOL)active
{
    if (active) {
        [self.view addSubview:searchBar];
        [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
            [searchBar moveTo:CGPointMake(0, 0)];
            tableView.frame = CGRectMake(0, searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - searchBar.frame.size.height);
        } completion:^(BOOL finished) { }];
       
    } else {
        [tableHeaderView addSubview:searchBar];
        tableView.frame = self.view.bounds;
        [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
            [searchBar moveTo:CGPointMake(0, 44)];
        } completion:^(BOOL finished) { }];
    }
    
    [tableView beginUpdates];
    tableView.tableHeaderView = active ? nil : tableHeaderView;
    [tableView endUpdates];
    
    [searchBar setShowsCancelButton:active animated:YES];
    [tableView setContentOffset:CGPointMake(0,0) animated:YES];
}

#pragma mark - search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    [self.view addSubview:searchBar];
    [self setFindModeActive:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)_searchBar
{
    NSLog(@"End editing");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    _searchBar.text = nil;
    [searchBar resignFirstResponder];
    
    [searchResultsList reset];
    [tableView reloadData];
    
    [self setFindModeActive:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar;
{
    [searchBar resignFirstResponder];
    
    [searchResultsList reset];
    [tableView reloadData];
    
    for (UIView *possibleButton in searchBar.subviews) {
        if ([possibleButton isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
    
    
}

@end
