//
//  GridButton.h
//  VKPhotoEditor
//
//  Created by asya on 11/24/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridModeButtonDelegate;

@interface GridModeButton : UIView

@property (nonatomic, unsafe_unretained) id<GridModeButtonDelegate> delegate;

- (IBAction)switchGridMode:(id)sender;

@end

@protocol GridModeButtonDelegate
- (void)gridModeButtonDidSwitchMode:(GridModeButton *)gridButton;
@end
