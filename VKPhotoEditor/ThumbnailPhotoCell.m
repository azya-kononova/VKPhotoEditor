//
//  LoadedPhotoCell.m
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ThumbnailPhotoCell.h"
#import "ThumbnailPhotoView.h"

@implementation ThumbnailPhotoCell {
    NSMutableArray *photoViews;
}

- (void)addLoadedPhotoView:(ThumbnailPhotoView *)view
{
    if (!photoViews) {
        photoViews = [NSMutableArray new];
    }
    
    [photoViews addObject:view];
    [photoViews sortUsingComparator:(NSComparator) ^(ThumbnailPhotoView *v1, ThumbnailPhotoView *v2) {
        NSUInteger t1 = v1.tag;
        NSUInteger t2 = v2.tag;
        return t1 == t2 ? NSOrderedSame : (t1 < t2 ? NSOrderedAscending : NSOrderedDescending);
    }];
}

- (void)displayPhotos:(NSArray *)photos
{
    for (NSUInteger i = 0; i < photoViews.count; ++i) {
        ThumbnailPhotoView *photoView = [photoViews objectAtIndex:i];
        
        if (i < photos.count) {
            photoView.hidden = NO;
            [photoView displayPhoto:[photos objectAtIndex:i]];
        } else {
            photoView.hidden = YES;
        }
    }
}

- (NSInteger)itemsInRow
{
    return 3;
}

#pragma mark XIBLoaderViewDelegate

- (void)xibLoaderView:(XIBLoaderView*)xibLoaderView replacedWithView:(UIView*)replacementView userParams:(NSArray*)userParams
{
    [self addLoadedPhotoView:(ThumbnailPhotoView *)replacementView];
}

@end
