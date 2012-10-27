//
//  VKTabBar.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/27/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VKTabBarDelegate;

@interface VKTabBar : UIView
@property (nonatomic, assign) id <VKTabBarDelegate> delegate;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *titles;

@property (nonatomic, assign) NSInteger selectedIndex;

- (IBAction)didSelect:(UIButton*)sender;
@end


@protocol VKTabBarDelegate
- (void)VKTabBar:(VKTabBar*)tabBar didSelectIndex:(NSInteger)index;
@end