//
//  CloudOverlayView.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptionTemplateProtocol.h"
#import "SPUserResizableView.h"

@interface ComicsCaptionView : UIView <CaptionTemplateProtocol>
@property (nonatomic, strong) IBOutlet UILabel *captionLabel;
@property (nonatomic, strong) IBOutlet SPUserResizableView *labelView;
@end
