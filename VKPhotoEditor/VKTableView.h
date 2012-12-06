//
//  VKTableView.h
//  VKPhotoEditor
//
//  Created by Kate on 12/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "UploadingView.h"

@interface VKTableView : PullTableView
@property (nonatomic, strong) IBOutlet UploadingView *uploadingView;
@end
