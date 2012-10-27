//
//  UserAccount.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, assign, readonly) NSInteger accountId;

+ (id)accountWithDict:(NSDictionary*)dict;
@end
