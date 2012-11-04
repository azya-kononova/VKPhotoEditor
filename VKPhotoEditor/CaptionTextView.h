//
//  StretchableTextField.h
//  VKPhotoEditor
//
//  Created by asya on 10/31/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CaptionTextViewDelegate;

@interface CaptionTextView : UIView

@property (nonatomic, unsafe_unretained) id<CaptionTextViewDelegate> delegate;
@property (nonatomic, strong) NSString *captionButtonTitle;
@property (nonatomic, strong, readonly) NSString *caption;

@end

@protocol CaptionTextViewDelegate
- (void)captionTextViewDidStartEditing:(CaptionTextView *)view;
- (void)captionTextViewDidFinishEditing:(CaptionTextView *)view;
@end
