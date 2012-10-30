//
//  PhotoManageBaseController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CroppingViewController.h"
#import "PhotoEditController.h"
#import "TakePhotoController.h"

@interface PhotoManageBaseController : UIViewController <PhotoEditControllerDelegate, CroppingViewControllerDelegate, TakePhotoControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL isPhoto;

- (void)takePhoto;
- (void)choosePhoto;
- (void)cropPhoto:(UIImage*)photo;
@end
