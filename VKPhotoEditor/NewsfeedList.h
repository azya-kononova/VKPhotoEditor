//
//  NewsfeedList.h
//  VKPhotoEditor
//
//  Created by asya on 12/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoList.h"

@interface NewsfeedList : PhotoList
@property (nonatomic, assign, readonly) NSInteger newsfeedCount;
- (void)saveSinceValue;
@end
