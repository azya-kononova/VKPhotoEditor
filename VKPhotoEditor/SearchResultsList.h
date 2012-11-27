//
//  AllPhotosList.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Account.h"
#import "PhotoList.h"

@interface SearchResultsList : PhotoList

- (void)loadNextPageFor:(NSString*)query;
- (void)deletePhoto:(NSString *)photoId;
@end


