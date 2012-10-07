//
//  PolaroidOverlayView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptionTemplateProtocol.h"

@interface PolaroidCaptionView : UIView <CaptionTemplateProtocol>
@property (nonatomic, strong) IBOutlet UILabel *captionLabel;
@end
