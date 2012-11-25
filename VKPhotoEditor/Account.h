//
//  Account.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteImage.h"

@interface Account : NSObject <NSCoding>
@property (nonatomic, strong) NSString *login;
@property (nonatomic, assign, readonly) NSInteger accountId;
@property (nonatomic, strong) NSURL *avatarUrl;

@property (nonatomic, strong, readonly) RemoteImage *avatar;

- (id)initWithID:(NSInteger)_id;
+ (id)accountWithDict:(NSDictionary*)dict;
@end
