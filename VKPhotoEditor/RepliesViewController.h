//
//  RepliesViewController.h
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "PullTableView.h"

@class VKPhoto;

@protocol RepliesViewControllerDelegate;

@interface RepliesViewController : UIViewController
@property (nonatomic, unsafe_unretained) id<RepliesViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet PullTableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UILabel* noPhotosLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@protocol RepliesViewControllerDelegate
- (void)repliesViewController:(RepliesViewController *)controller didSelectAccount:(Account*)account;
- (void)repliesViewController:(RepliesViewController *)controller didReplyToPhoto:(VKPhoto *)photo;
- (void)repliesViewController:(RepliesViewController *)controller presenModalViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)repliesViewController:(RepliesViewController *)controller dismissModalViewController:(UIViewController *)controller animated:(BOOL)animated;
@end

