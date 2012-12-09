//
//  FollowersList.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 12/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FollowersList.h"
#import "NSDictionary+Helpers.h"

NSString *FollowersFilterFollowing = @"following";
NSString *FollowersFilterFollower = @"follower";

@implementation FollowersList
@synthesize account;
@synthesize filter;

- (id)init
{
    if (self = [super init]) {
        self.limit = 100;
    }
    return self;
}

- (VKRequestExecutor*)newPageExec
{
    return [service getFollowers:account.accountId offset:self.photos.count limit:self.limit filter:nil];
}

- (void)mapData:(id)data
{
    NSMutableArray *accounts = [NSMutableArray new];
    
    NSInteger followed_back_count = [self numberOfItemsInSection:0];
    NSInteger following_count = [self numberOfItemsInSection:1];
    NSInteger follower_count = [self numberOfItemsInSection:2];
    
    for (NSDictionary *user in [data objectForKey:@"list"]) {
        Account *acc = [user integerForKey:@"id"] == service.profile.accountId ? service.profile : [Account accountWithDict:[user objectForKey:@"user"]];
        [accounts addObject:acc];
        NSString *type = [user objectForKey:@"type"];
        if ([type isEqualToString:@"followed_back"])
            followed_back_count++;
        else if ([type isEqualToString:@"follower"])
            follower_count++;
        else if ([type isEqualToString:@"following"])
            following_count++;
    }
    
    [self.sectionsInfo setObject:[NSNumber numberWithInt:followed_back_count] forKey:[NSNumber numberWithInt:0]];
    [self.sectionsInfo setObject:[NSNumber numberWithInt:following_count] forKey:[NSNumber numberWithInt:1]];
    [self.sectionsInfo setObject:[NSNumber numberWithInt:follower_count] forKey:[NSNumber numberWithInt:2]];
    
    [self append:accounts totalCount:[[data objectForKey:@"count"] integerValue]];
}

@end
