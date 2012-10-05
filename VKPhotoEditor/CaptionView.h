//
//  CaptionView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CaptionViewDelegate;

@class CustomSegmentView;

@interface CaptionView : UIView
@property (nonatomic, assign) IBOutlet id<CaptionViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet CustomSegmentView *fontSegmentView;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong, readonly) NSString *caption;
@property (nonatomic, strong, readonly) UIFont *selectedFont;

- (IBAction)textFieldReturn:(id)sender;
@end

@protocol CaptionViewDelegate
- (void)captionViewdidChange:(CaptionView*)captionView;
- (void)captionView:(CaptionView*)captionView didSetFont:(UIFont*)font;
@end
