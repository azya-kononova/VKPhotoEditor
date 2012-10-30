//
//  NSArray+Helpers.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

typedef BOOL (^Pred)(id);

@interface NSArray (Helpers)

- (id)find:(Pred)pred;
- (id)find:(Pred)pred index:(NSUInteger*)index;

@end

