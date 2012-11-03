//
//  PhotosListControllerController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoManageBaseController.h"
#import "ImageToUpload.h"

@interface PhotosListController : PhotoManageBaseController
- (id)initWithImageToUpload:(ImageToUpload*)image;
@end
