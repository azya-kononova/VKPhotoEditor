//
//  ErrorMessage.m
//  VKPhotoEditor
//
//  Created by asya on 11/19/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ErrorMessage.h"

#define MIN_USERNAME_LENGTH 4
#define MIN_USERNAME_LENGTH_ERROR @"Username is too short"

@implementation ErrorMessage

+ (NSString *)loginMessageWithError:(NSError *)error loginData:(NSString *)data
{
    if (error.code == 400 && data.length < MIN_USERNAME_LENGTH) {
        return MIN_USERNAME_LENGTH_ERROR;
    }
    
    return error.localizedDescription;
}

@end
