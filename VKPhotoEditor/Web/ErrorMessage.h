//
//  ErrorMessage.h
//  VKPhotoEditor
//
//  Created by asya on 11/19/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorMessage : NSObject

+ (NSString *)loginMessageWithError:(NSError *)error loginData:(NSString *)data;

@end
