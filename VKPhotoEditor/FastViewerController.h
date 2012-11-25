//
//  FastViewerController.h
//  VKPhotoEditor
//
//  Created by asya on 11/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhoto.h"

@protocol FastViewerControllerDelegate;

@interface FastViewerController : UIViewController

@property (nonatomic, unsafe_unretained) id<FastViewerControllerDelegate> delegate;

- (id)initWithPhoto:(VKPhoto *)photo ;

@end

@protocol FastViewerControllerDelegate
- (void)fastViewerControllerDidFinish:(FastViewerController *)controller;
@end