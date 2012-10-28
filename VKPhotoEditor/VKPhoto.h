//
//  VKPhoto.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteImage.h"
#import "Account.h"

@interface VKPhoto : NSObject
@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) Account *account;

@property (nonatomic, strong, readonly) RemoteImage *photo;

+ (id)VKPhotoWithDict:(NSDictionary*)dict;
@end
