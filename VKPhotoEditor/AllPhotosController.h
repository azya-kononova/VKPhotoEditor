//
//  AllPhotosController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListManagerBaseController.h"

@interface AllPhotosController : ListManagerBaseController <UISearchBarDelegate>
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
- (void)search:(NSString*)query;
@end

