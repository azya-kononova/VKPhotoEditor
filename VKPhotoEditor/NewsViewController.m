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
    
    isBadgeUsed = NO;
}

@end
