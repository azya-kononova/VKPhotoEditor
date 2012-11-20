//
//  VKTabBar.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TabBarStateUnselected = -1,
    TabBarStateProfile = 0,
    TabBarStateAllPhotos = 1
} TabBarState;

@protocol VKTabBarDelegate;

@interface VKTabBar : UIView
@property (nonatomic, assign) id <VKTabBarDelegate> delegate;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *titles;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;

@property (nonatomic, assign) TabBarState state;

- (IBAction)didSelect:(UIButton*)sender;
- (IBAction)central;
@end


@protocol VKTabBarDelegate
- (void)VKTabBar:(VKTabBar*)tabBar didSelectIndex:(NSInteger)index;
- (void)VKTabBarDidTapCentral:(VKTabBar*)tabBar;
@end