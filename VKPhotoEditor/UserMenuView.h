//
//  UserMenuView.h
//  VKPhotoEditor
//
//  Created by Kate on 12/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlexibleButton.h"

@protocol UserMenuViewDelegate;

@interface UserMenuView : UIView
@property (nonatomic, strong) id<UserMenuViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet FlexibleButton *actionButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *cancelButton;

- (void)show:(BOOL)show;

- (IBAction)cancel;
- (IBAction)action;
@end

@protocol UserMenuViewDelegate
- (void)userMenuViewDidTapAction:(UserMenuView*)view;
- (void)userMenuViewDidCancel:(UserMenuView*)view;
@end


