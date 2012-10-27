//
//  VKTabBar.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKTabBar.h"

@implementation VKTabBar
@synthesize buttons;
@synthesize titles;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    for (UIButton *button in buttons) {
        button.selected = (button.tag == selectedIndex);
    }
    for (UILabel *label in titles) {
        label.textColor = label.tag == selectedIndex ? [UIColor whiteColor] : [UIColor grayColor];
    }
    [delegate VKTabBar:self didSelectIndex:selectedIndex];
}

- (IBAction)didSelect:(UIButton*)sender
{
    self.selectedIndex = sender.tag;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
