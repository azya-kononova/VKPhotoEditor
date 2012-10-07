//
//  TakePhotoController.h
//  VKPhotoEditor
//
//  Created by asya on 9/30/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TakePhotoControllerDelegate;

@interface TakePhotoController : UIViewController
@property (nonatomic, assign) id<TakePhotoControllerDelegate> delegate;
@end

@protocol TakePhotoControllerDelegate
- (void)takePhotoControllerDidCancel:(TakePhotoController *)controller;
- (void)takePhotoController:(TakePhotoController *)controller didFinishWithBasicImage:(UIImage *)basic filterIndex:(NSInteger)index userInfo:(NSDictionary *)userInfo;
@end


