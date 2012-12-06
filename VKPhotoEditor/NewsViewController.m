//
//  NewsViewController.m
//  VKPhotoEditor
//
//  Created by asya on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "NewsViewController.h"
#import "ReplyPhotoCell.h"
#import "NewsfeedList.h"
#import "PhotoUpdatesLoader.h"

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    photoList = [NewsfeedList new];
    photoList.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Send -1 for reset badge
    [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateNewsfeedBadge object:[NSNumber numberWithInt:-1]];
    [photoList loadMore];
}

#pragma mark - PhotosListDelegate


- (void)photoList:(PhotoList *)_photoList didUpdatePhotos:(NSArray *)photos
{
    [super photoList:_photoList didUpdatePhotos:photos];
    [(NewsfeedList *)photoList saveSinceValue];
}
@end
