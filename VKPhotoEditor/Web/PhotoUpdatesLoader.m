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
NSString *VKHideRepliesBadge = @"VKHideRepliesBadge";

@interface RepliesUpdateList : MentionList
@end

@implementation RepliesUpdateList

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:service.profile.accountId since:service.replySince after:nil limit:self.limit];
}

@end


@interface PhotoUpdatesLoader ()<PhotoListDelegate>

@end
@implementation PhotoUpdatesLoader {
    RepliesUpdateList *mentionList;
    
    NSTimer *mentionTimer;
}

#pragma mark - PhotoListDelegate

- (id)init
{
    self = [super init];
    if (self) {
        mentionList = [RepliesUpdateList new];
        mentionList.delegate = self;
    }
    return self;
}

- (void)start
{
    [mentionList loadMore];
    
    mentionTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:mentionList selector:@selector(loadMore) userInfo:nil repeats:YES];
}

- (void)stop
{
    [mentionTimer invalidate];
    mentionTimer = nil;
}

- (void)dealloc
{
    [self stop];
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    if (mentionList.mentionsCount + 4
        ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateRepliesBadge object:[NSNumber numberWithInt:mentionList.mentionsCount] userInfo:nil];
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error {}

@end
