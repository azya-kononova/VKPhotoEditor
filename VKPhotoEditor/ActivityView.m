//
//  ActivityView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/7/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ActivityView.h"
#import "CALayer+Animations.h"

@implementation ActivityView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.hidden = YES;

}

- (void)showSelf:(BOOL)show
{
    [self.layer fade].duration = 0.2;
    self.hidden = !show;
}



@end
