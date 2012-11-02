//
//  InformationView.h
//  Radario
//
//  Created by Ekaterina Petrova on 5/24/12.
//  Copyright (c) 2012 vladimir.chernokulsky@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationView : UIView

- (void)showMessage:(NSString*)message withTimeout:(NSTimeInterval)timeout;
- (void)showMessage:(NSString *)message;

@end
