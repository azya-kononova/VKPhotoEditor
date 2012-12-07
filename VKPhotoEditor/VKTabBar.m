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

@implementation VKTabBar {
    CGSize initBadgeSize;
    NSInteger repliesCount;
}

@synthesize buttons;
@synthesize titles;
@synthesize delegate;
@synthesize backgroundView;
@synthesize replyBadge;
@synthesize state;

- (void)awakeFromNib
{
    backgroundView.backgroundColor = [UIColor tabBarBgColor];
    replyBadge.bgImagecaps = CGSizeMake(13, 10);
    initBadgeSize = replyBadge.frame.size;
    
    //TODO: use two different badges for that
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReplyBadge:) name:VKUpdateRepliesBadge object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReplyBadge:) name:VKUpdateNewsfeedBadge object:nil];
}

- (void)setState:(TabBarState)_state
{
//    if (state == _state) return;
    
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

- (void)updateReplyBadge:(NSNotification *)notification
{
    NSInteger count = [notification.object integerValue];
    
    repliesCount = count < 0 ? 0 : repliesCount + count;
    
    NSString *badgeTitle = [NSString stringWithFormat:@"%d", repliesCount];
    [replyBadge setTitle:badgeTitle forState:UIControlStateNormal];
    replyBadge.hidden = !repliesCount;
    
    CGSize titleSize = [badgeTitle sizeWithFont:replyBadge.titleLabel.font];
    
    if (titleSize.width + REPLY_BADGE_OFFSET > initBadgeSize.width) {
        [replyBadge resizeTo:CGSizeMake(titleSize.width + REPLY_BADGE_OFFSET, initBadgeSize.height)];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
