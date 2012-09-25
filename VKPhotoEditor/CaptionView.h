//
//  CaptionView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomSegmentView;

@interface CaptionView : UIView
@property (nonatomic, strong) IBOutlet CustomSegmentView *fontSegmentView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (IBAction)textFieldReturn:(id)sender;
@end
