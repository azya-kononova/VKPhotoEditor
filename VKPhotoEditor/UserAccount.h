//
//  UserAccount.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface UserAccount : NSObject
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *lastPhotos;

+ (id)accountWithDict:(NSDictionary*)dict;
@end
