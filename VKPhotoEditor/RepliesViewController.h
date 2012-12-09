//
//  RepliesViewController.h
//  VKPhotoEditor
//
//  Created by asya on 12/1/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListManagerBaseController.h"

@interface RepliesViewController : ListManagerBaseController {
    BOOL isBadgeUsed;
}

- (id)initWithProfile:(UserProfile *)_profile;

@end

