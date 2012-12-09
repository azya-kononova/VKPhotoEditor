//
//  VKTabBar.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKTabBar.h"
#import "UIColor+VKPhotoEditor.h"
#import "PhotoUpdatesLoader.h"
#import "UIView+Helpers.h"

#define REPLY_BADGE_OFFSET 14
#define HIDDEN_TAB_X_VALUE -321

@implementation VKTabBar {
    CGSize initBadgeSize;
    NSArray *tabsOrigins;
    NSArray *tabsOriginsExended;
}

@synthesize buttons;
@synthesize titles;
@synthesize delegate;
@synthesize backgroundView;
@synthesize replyBadge;
@synthesize state;
@synthesize extended;
@synthesize tabViews;

- (void)awakeFromNib
{
    backgroundView.backgroundColor = [UIColor tabBarBgColor];
    replyBadge.bgImagecaps = CGSizeMake(13, 10);
    initBadgeSize = replyBadge.frame.size;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReplyBadge:) name:VKUpdateRepliesBadge object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideReplyBadge) name:VKHideRepliesBadge object:nil];
    
    tabsOriginsExended = [NSArray arrayWithObjects:
                   [NSValue valueWithCGPoint:CGPointMake(0, 1)],
                   [NSValue valueWithCGPoint:CGPointMake(60, 0)],
                   [NSValue valueWithCGPoint:CGPointMake(205, 0)],
                   [NSValue valueWithCGPoint:CGPointMake(260, 0)],
                   nil];
    
    tabsOrigins = [NSArray arrayWithObjects:
                   [NSValue valueWithCGPoint:CGPointMake(HIDDEN_TAB_X_VALUE, 0)],
                   [NSValue valueWithCGPoint:CGPointMake(30, 0)],
                   [NSValue valueWithCGPoint:CGPointMake(HIDDEN_TAB_X_VALUE, 0)],
                   [NSValue valueWithCGPoint:CGPointMake(233, 0)],
                   nil];
    
}

- (void)setExtended:(BOOL)_extended
{
    if (extended == _extended) return;
    
    extended = _extended;
    
    NSArray *origins = _extended ? tabsOriginsExended : tabsOrigins;
    
    for (UIView *view in tabViews) {
        CGPoint tabOrigin = [origins[view.tag] CGPointValue];
        view.hidden = tabOrigin.x == HIDDEN_TAB_X_VALUE;
        if (!view.hidden) [view moveTo:tabOrigin];
    }
}

- (void)setExtended:(BOOL)_extended animated:(BOOL)animated
{
    [UIView animateWithDuration:0.4 delay:0 options: UIViewAnimationCurveEaseOut animations:^{
        [self setExtended:_extended];
    } completion:nil];
}

- (void)setState:(TabBarState)_state
{
    state = _state;
    
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

- (void)updateBadge:(FlexibleButton*)badge value:(NSInteger)value
{
    NSInteger count = value < 0 ? 0 : badge.titleLabel.text.integerValue + value;
    
    NSString *badgeTitle = [NSString stringWithFormat:@"%d", count];
    [badge setTitle:badgeTitle forState:UIControlStateNormal];
    badge.hidden = !count;
    
    CGSize titleSize = [badgeTitle sizeWithFont:badge.titleLabel.font];
    
    if (titleSize.width + REPLY_BADGE_OFFSET > initBadgeSize.width) {
        [badge resizeTo:CGSizeMake(titleSize.width + REPLY_BADGE_OFFSET, initBadgeSize.height)];
    }
}

- (void)updateReplyBadge:(NSNotification *)notification
{
    if (state == TabBarStateReply) return;
    [self updateBadge:replyBadge value:[notification.object integerValue]];
}

- (void)hideReplyBadge
{
    replyBadge.hidden = YES;
    NSString *badgeTitle = [NSString stringWithFormat:@"%d", 0];
    [replyBadge setTitle:badgeTitle forState:UIControlStateNormal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
