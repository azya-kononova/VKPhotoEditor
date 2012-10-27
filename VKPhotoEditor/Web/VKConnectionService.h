//
//  VKConnectionService.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserAccount.h"
#import "VKRequestExecutor.h"

extern NSString *VKErrorDomain;

@interface VKConnectionService : NSObject

@property (nonatomic, strong, readonly) NSURL *rootURL;
@property (nonatomic, strong, readonly) UserAccount *account;

+ (VKConnectionService*)shared;

- (id)initWithURL:(NSURL*)url;

- (VKRequestExecutor*)login:(NSString*)login;
- (VKRequestExecutor*)uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption;

@end
