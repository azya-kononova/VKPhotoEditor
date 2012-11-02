//
//  CaptionTemplateProtocol.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CaptionTemplateDelegate;

@protocol CaptionTemplateProtocol <NSObject>
@property (nonatomic, assign) id<CaptionTemplateDelegate> delegate;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong, readonly) UIColor *textColor;
@property (nonatomic, strong, readonly) UIImageView *templateImage;
@end

@protocol CaptionTemplateDelegate
- (void)captionTemplateStartEditing:(UIView<CaptionTemplateProtocol>*)captionTemplate;
- (void)captionTemplateEndEditing:(UIView<CaptionTemplateProtocol>*)captionTemplate;
@end