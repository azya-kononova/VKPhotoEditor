//
//  AllPhotosController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@protocol AllPhotosControllerDelegate;

@interface AllPhotosController : UIViewController <UISearchBarDelegate>
@property (nonatomic, assign) id<AllPhotosControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

- (void)search:(NSString*)query;
@end

@protocol AllPhotosControllerDelegate
- (void)allPhotosController:(AllPhotosController*)ctrl didSelectAccount:(Account*)account;
@end
