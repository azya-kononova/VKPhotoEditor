//
//  Multipart.h
//  Radario
//
//  Created by Sergey Martynov on 09.02.12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import "FileUpload.h"

@interface Multipart : NSObject
@property (nonatomic, strong, readonly) NSString *boundary;

- (id)initWithBoundary:(NSString*)boundary;

- (void)appendName:(NSString*)name value:(id)value;
- (void)appendName:(NSString*)name fileUpload:(FileUpload*)upload;

- (NSData*)getData;

@end
