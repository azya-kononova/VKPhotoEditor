//
//  AppDelegate.h
//  VKPhotoEditor
//
//  Created by asya on 9/21/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKConnectionService.h"
#import "Settings.h"
#import "ImageCache.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic, strong) VKConnectionService *connectionService;
@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) ImageCache *imageCache;

+ (AppDelegate*)shared;
@end
