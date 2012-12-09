//
//  ListManagerBaseController.h
//  VKPhotoEditor
//
//  Created by asya on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhoto.h"
#import "Account.h"
#import "PullTableView.h"
#import "PhotoList.h"
#import "ThumbnailPhotoCell.h"
#import "FastViewerController.h"
#import "PhotoCell.h"
#import "VKViewController.h"
#import "VKTableView.h"

@protocol ListManagerBaseControllerDelegate;

@interface ListManagerBaseController : VKViewController <ThumbnailPhotoCellDelegate, FastViewerControllerDelegate, PhotoListDelegate, PhotoCellDelegate, PullTableViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    PhotoList *photoList;
    NSInteger itemsInRow;
    NSInteger gridCellHeight;
    
    BOOL isGridMode;
    BOOL isFastViewerOpen;
}

@property (nonatomic, unsafe_unretained) id<ListManagerBaseControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UILabel* noPhotosLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readonly) NSArray *gridPhotoList;

- (NSArray *)getPhotosForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)changeGridMode:(UIButton*)sender;

@end

@protocol ListManagerBaseControllerDelegate <NSObject>
- (void)listBaseController:(ListManagerBaseController*)ctrl didSelectAccount:(Account*)account animated:(BOOL)animated;
- (void)listBaseController:(ListManagerBaseController*)ctrl presenModalViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)listBaseController:(ListManagerBaseController*)ctrl dismissModalViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)listBaseController:(ListManagerBaseController*)ctrl didReplyToPhoto:(VKPhoto *)photo;
- (void)listBaseController:(ListManagerBaseController*)ctrl didSelectHashTag:(NSString *)tag;
@end
