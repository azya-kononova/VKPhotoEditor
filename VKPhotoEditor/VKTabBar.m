//
//  VKTabBar.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKTabBar.h"
#import "UIColor+VKPhotoEditor.h"

@implementation VKTabBar
@synthesize buttons;
@synthesize titles;
@synthesize delegate;
@synthesize backgroundView;

- (void)awakeFromNib
{
    backgroundView.backgroundColor = [UIColor tabBarBgColor];
}

- (void)setState:(TabBarState)state
{
    for (UIButton *button in buttons) {
        button.selected = (button.tag == state);
    }
    for (UILabel *label in titles) {
        label.textColor = label.tag == state ? [UIColor whiteColor] : [UIColor grayColor];
    }
    if (state != TabBarStateUnselected) [delegate VKTabBar:self didSelectIndex:state];
}

- (IBAction)didSelect:(UIButton*)sender
{
    self.state = sender.tag;
}

- (IBAction)central
{
    [delegate VKTabBarDidTapCentral:self];
}

@end
