//
//  RepliesUpdate.m
//  VKPhotoEditor
//
//  Created by asya on 12/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RepliesUpdate.h"
#import "MentionList.h"

#define TIME_INTERVAL 60

@interface RepliesUpdateList : MentionList
@end

@implementation RepliesUpdateList

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:service.profile.accountId since:service.since after:nil limit:limit];
}

@end

@interface RepliesUpdate ()<PhotoListDelegate>

@end
@implementation RepliesUpdate {
    RepliesUpdateList *mentionList;
    NSTimer *timer;
}

#pragma mark - PhotoListDelegate

- (id)init
{
    self = [super init];
    if (self) {
        mentionList = [[RepliesUpdateList alloc] init];
        mentionList.delegate = self;
    }
    return self;
}

- (void)start
{
    timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:mentionList selector:@selector(loadMore) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    if (photos.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_REPLIES_LIST object:[NSNumber numberWithInt:photos.count] userInfo:nil];
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error {}

@end
