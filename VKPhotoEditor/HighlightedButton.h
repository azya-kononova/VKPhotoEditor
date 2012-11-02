//
//  MyButton.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 11/2/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HighlightedButtonDelegate;

@interface HighlightedButton : UIButton
@property (nonatomic, assign) IBOutlet id<HighlightedButtonDelegate> delegate;
@end

@protocol HighlightedButtonDelegate <NSObject>
- (void)highlightedButton:(HighlightedButton*)button didBecameHighlighted:(BOOL)highlighted;
@end
