//
//  FastViewerController.h
//  VKPhotoEditor
//
//  Created by asya on 11/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhoto.h"
#import "Account.h"

@protocol FastViewerControllerDelegate;

@interface FastViewerController : UIViewController

@property (nonatomic, unsafe_unretained) id<FastViewerControllerDelegate> delegate;

- (id)initWithPhoto:(VKPhoto *)photo;
- (IBAction)goBack;
- (IBAction)showProfile;

@end

@protocol FastViewerControllerDelegate
- (void)fastViewerControllerDidFinish:(FastViewerController *)controller;
- (void)fastViewerController:(FastViewerController *)controller didFinishWithAccount:(Account*)account;
@end