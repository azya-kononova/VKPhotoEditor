//
//  VKViewController.h
//  VKPhotoEditor
//
//  Created by Kate on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKTableView.h"

@interface VKViewController : UIViewController {
IBOutlet VKTableView *photosTableView;
}

- (void)showUploading:(UIImage*)image;
- (void)displayProgress:(CGFloat)progress;
- (void)cancelUpload:(BOOL)success;

@end
