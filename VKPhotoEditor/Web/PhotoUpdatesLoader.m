//
//  RepliesUpdate.m
//  VKPhotoEditor
//
//  Created by asya on 12/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoUpdatesLoader.h"
#import "MentionList.h"
#import "NewsfeedList.h"

#define TIME_INTERVAL 60

NSString *VKUpdateRepliesBadge = @"VKUpdateRepliesBadge";
NSString *VKUpdateNewsfeedBadge = @"VKUpdateNewsfeedBadge";

@interface RepliesUpdateList : MentionList
@end

@implementation RepliesUpdateList

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:service.profile.accountId since:service.replySince after:nil limit:limit];
}

@end

@interface NewsfeedUpdateList : NewsfeedList
@end

@implementation NewsfeedUpdateList

- (VKRequestExecutor*)newPageExec
{
    return [service getNewsfeedSince:service.newsfeedSince after:nil limit:limit];
}

@end


@interface PhotoUpdatesLoader ()<PhotoListDelegate>

@end
@implementation PhotoUpdatesLoader {
    RepliesUpdateList *mentionList;
    NewsfeedUpdateList *newsfeedList;
    
    NSTimer *mentionTimer;
    NSTimer *newsfeedTimer;
}

#pragma mark - PhotoListDelegate

- (id)init
{
    self = [super init];
    if (self) {
        mentionList = [RepliesUpdateList new];
        mentionList.delegate = self;
        
        newsfeedList = [NewsfeedUpdateList new];
        newsfeedList.delegate = self;
    }
    return self;
}

- (void)start
{
    [mentionList loadMore];
    [newsfeedList loadMore];
    
    mentionTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:mentionList selector:@selector(loadMore) userInfo:nil repeats:YES];
    newsfeedTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:newsfeedList selector:@selector(loadMore) userInfo:nil repeats:YES];
}

- (void)stop
{
    [mentionTimer invalidate];
    [newsfeedTimer invalidate];
    
    mentionTimer = nil;
    newsfeedTimer = nil;
}

- (void)dealloc
{
    [self stop];
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    if ([photoList isKindOfClass:[MentionList class]] && mentionList.mentionsCount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateRepliesBadge object:[NSNumber numberWithInt:mentionList.mentionsCount] userInfo:nil];
    }
    if ([photoList isKindOfClass:[NewsfeedList class]] && newsfeedList.newsfeedCount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateNewsfeedBadge object:[NSNumber numberWithInt:newsfeedList.newsfeedCount] userInfo:nil];
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error {}

@end
