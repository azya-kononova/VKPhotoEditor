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
#import "RequestExecutorDelegateAdapter.h"
#import "VKConnectionService.h"
#import "UIColor+VKPhotoEditor.h"

@interface AllPhotosController () <UIActionSheetDelegate>
@end

@implementation AllPhotosController {
    NSInteger selectedPhoto;
    RequestExecutorDelegateAdapter *adapter;
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
    
    selectedPhoto = -1;
    adapter = [[RequestExecutorDelegateAdapter alloc] initWithTarget:self];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressOnTable:)];
    recognizer.minimumPressDuration = 2.0;
    [photosTableView addGestureRecognizer:recognizer];
}


#pragma mark - Internals

- (NSArray *)gridPhotoList
{
    return photoList.photos;
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TODO: handle situations when users find
   return isGridMode ? gridCellHeight : 366;
    
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
    Account *account = [[photoList.photos objectAtIndex:selectedPhoto] account];
    return account.accountId == [VKConnectionService shared].profile.accountId;
}

- (void)reload
{
    self.noPhotosLabel.hidden = YES;
    [photoList reset];
    [photosTableView reloadData];
    [photoList loadMore];
}

#pragma mark - PhotoCellDelegate

- (void)photoCell:(PhotoCell*)photoCell didTapHashTag:(NSString*)hashTag
{
    [self search:hashTag];
}

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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        VKPhoto *photo = [photoList.photos objectAtIndex:selectedPhoto];
        [adapter start:[[VKConnectionService shared] deletePhoto:photo.photoId] onSuccess:@selector(exec: didDeletePhoto:) onError:@selector(exec: didFailWithError:)];
    } else if (buttonIndex == 1) {
        VKPhoto *photo = [photoList.photos objectAtIndex:selectedPhoto];
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
    if ([ids count]) [(SearchResultsList *)photoList deletePhoto:[ids objectAtIndex:0]];
}


#pragma mark - UILongPressGestureRecognizer

-(void)handleLongPressOnTable:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint point = [recognizer locationInView:photosTableView];
    NSIndexPath *indexPath = [photosTableView indexPathForRowAtPoint:point];
    
    if (indexPath) {
        
        if (isGridMode) return;
        
        if (indexPath.row % 2 == 0) {
            [self.delegate listBaseController:self didSelectAccount:[[photoList.photos objectAtIndex:indexPath.row/2] account] animated:YES];
            return;
        }
        
        selectedPhoto = (indexPath.row - 1) / 2;
        
        if (![self isProfilePhoto]) return;
        
        UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"Delete Image"
                                                     otherButtonTitles:@"Save Image",nil];
        actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actSheet showInView:self.view.superview];
    }
}

@end
