//
//  AllPhotosList.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@protocol SearchResultsListDelegate;

@interface SearchResultsList : NSObject
@property (nonatomic, assign) id<SearchResultsListDelegate> delegate;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) Account *user;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign, readonly) BOOL completed;

- (void)reset;
- (void)loadNextPageFor:(NSString*)query;
- (void)deletePhoto:(NSString *)photoId;

@end

@protocol SearchResultsListDelegate
- (void)searchResultsList:(SearchResultsList*)photosList didUpdatePhotos:(NSArray*)photos user:(Account*)user;
- (void)searchResultsList:(SearchResultsList *)photosList didFailToUpdate:(NSError*)error;
@end

