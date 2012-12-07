//
//  VKTabBar.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlexibleButton.h"

typedef enum {
    TabBarStateUnselected = -1,
    TabBarStateHome = 0,
    TabBarStateExplore = 1,
    TabBarStateReply = 2,
    TabBarStateProfile = 3,
} TabBarState;

@protocol VKTabBarDelegate;

@interface VKTabBar : UIView
@property (nonatomic, assign) id <VKTabBarDelegate> delegate;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *titles;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *tabViews;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet FlexibleButton *replyBadge;
@property (nonatomic, strong) IBOutlet FlexibleButton *newsBadge;

@property (nonatomic, assign) TabBarState state;
@property (nonatomic, assign) BOOL extended;

- (void)setExtended:(BOOL)extended animated:(BOOL)animated;

- (IBAction)didSelect:(UIButton*)sender;
- (IBAction)central;
@end


@protocol VKTabBarDelegate
- (void)VKTabBar:(VKTabBar*)tabBar didSelectIndex:(NSInteger)index;
- (void)VKTabBarDidTapCentral:(VKTabBar*)tabBar;
@end