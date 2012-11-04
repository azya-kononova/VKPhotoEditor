//
//  AllPhotosController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "PullTableView.h"

@protocol AllPhotosControllerDelegate;

@interface AllPhotosController : UIViewController <UISearchBarDelegate>
@property (nonatomic, assign) id<AllPhotosControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet PullTableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UILabel* noPhotosLabel;

- (void)search:(NSString*)query;
@end

@protocol AllPhotosControllerDelegate
- (void)allPhotosController:(AllPhotosController*)ctrl didSelectAccount:(Account*)account;
@end
