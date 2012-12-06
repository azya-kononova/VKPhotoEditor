//
//  FollowersList.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 12/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoList.h"

extern NSString *FollowersFilterFollowing;
extern NSString *FollowersFilterFollower;

@interface FollowersList : PhotoList
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) NSString *filter;

@end
