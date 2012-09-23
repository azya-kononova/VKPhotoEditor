//
//  FlexibleButton.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FlexibleButton.h"

@implementation FlexibleButton {
    UIEdgeInsets origImgInsets;
    NSMutableDictionary *images;
}
@synthesize bgImagecaps;

- (void)setBgImagecaps:(CGSize)_bgImagecaps
{
    bgImagecaps = _bgImagecaps;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (!CGSizeEqualToSize(bgImagecaps, CGSizeZero)) {
        if (!images) images = [NSMutableDictionary new];
        UIControlState states[] = { UIControlStateNormal, UIControlStateHighlighted, UIControlStateDisabled };
        for (int i = 0; i < sizeof(states) / sizeof(states[0]); ++i) {
            UIControlState state = states[i];
            UIImage *image = [self backgroundImageForState:state];
            if (image) {
                NSString *key = [NSString stringWithFormat:@"bg_%d", state];
                if (image != [images objectForKey:key]) {
                    image = [image stretchableImageWithLeftCapWidth:bgImagecaps.width topCapHeight:bgImagecaps.height];
                    [images setObject:image forKey:key];
                    [self setBackgroundImage:image forState:state];
                }
            }
        }
    }
    UIEdgeInsets insets = self.imageEdgeInsets;
    if (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
        if (UIEdgeInsetsEqualToEdgeInsets(origImgInsets, UIEdgeInsetsZero)) {
            origImgInsets = insets;
        }
        if (origImgInsets.left < 0) {
            insets.left = self.bounds.size.width + origImgInsets.left;
        }
        if (origImgInsets.right < 0) {
            insets.right = self.bounds.size.width + origImgInsets.right;
        }
        self.imageEdgeInsets = insets;
    }
    [super layoutSubviews];
}

@end
