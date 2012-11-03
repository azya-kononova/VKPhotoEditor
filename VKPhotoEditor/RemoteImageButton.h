//
//  RemoteImageButton.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RemoteImage.h"

@interface RemoteImageButton : UIButton
@property (nonatomic, strong) RemoteImage *image;

- (void)displayImage:(RemoteImage*)remoteImage;
@end
