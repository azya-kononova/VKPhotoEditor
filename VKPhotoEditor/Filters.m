//
//  Filters.m
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "Filters.h"

@implementation Filters

+ (NSArray *)filters
{
    return [NSArray arrayWithObjects:[self image:@"Basic.png"],
            [self image:@"Filter1.png"],
            [self image:@"Filter2.png"],
            [self image:@"Filter3.png"],
            [self image:@"Filter4.png"],
            [self image:@"Filter5.png"],
            [self image:@"Filter6.png"],
            [self image:@"Filter7.png"],
            [self image:@"Filter8.png"],nil];
}

+ (UIImageView *)image:(NSString *)name
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
}

@end
