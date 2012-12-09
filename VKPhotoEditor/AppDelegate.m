//
//  AppDelegate.m
//  VKPhotoEditor
//
//  Created by asya on 9/21/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotosListController.h"
#import "StartViewController.h"
#import "InformationView.h"
#import "UIViewController+StatusBar.h"
#import "PhotoUpdatesLoader.h"
#import "VKRequestExecutor.h"

@interface AppDelegate () <VKRequestExecutorDelegate>
@end

@implementation AppDelegate {
    InformationView *informationView;
    PhotoUpdatesLoader *updatesLoader;
    NSMutableString *newToken;
    VKRequestExecutor *exec;
}

@synthesize window, navigationController, connectionService, settings, imageCache;

+ (AppDelegate*)shared
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
    settings = [[Settings alloc] initWithDefaults:dict];
    connectionService = [[VKConnectionService alloc] initWithURL:settings.serviceRootURL];
    imageCache = [ImageCache new];
    
    updatesLoader = [PhotoUpdatesLoader new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidFail:) name:VKRequestDidFailNotification object:connectionService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:VKRequestDidLogin object:connectionService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopReplyUpdates) name:VKRequestDidLogout object:connectionService];
    
    if (connectionService.profile.accessToken) {
        connectionService.replySince = [Settings current].replySince;
        [self startReplyUpdates];
    }
    
    self.navigationController.navigationBar.hidden = YES;
    navigationController.viewControllers = connectionService.profile.accessToken ? [NSArray arrayWithObjects: [StartViewController new], [PhotosListController new], nil] : [NSArray arrayWithObject:[StartViewController new]];
    
    informationView = [InformationView loadFromNIB];
    [self.window addSubview:informationView];
    [self.window bringSubviewToFront:informationView];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    const char *data = [deviceToken bytes];
    newToken = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++) {
        [newToken appendFormat:@"%02.2hhX", data[i]];
    }
    
   	NSLog(@"My token is: %@", newToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to register for push: %@", error.localizedDescription);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [settings setFirstLaunch:NO];
}

- (void)didLogin
{
    if (![newToken isEqualToString:settings.deviceToken]) {
        BOOL sandbox = 0;
#if DEBUG
        sandbox = 1;
#endif
        exec = [connectionService registerDevice:newToken sandbox:sandbox];
        exec.delegate = self;
        [exec start];
    }
    
    [self startReplyUpdates];
}

- (void)requestDidFail:(NSNotification*)n;
{
    NSError *error = [n.userInfo objectForKey:@"Error"];
    [informationView showMessage:error.localizedDescription];
}

- (void)startReplyUpdates
{
    [updatesLoader start];
}

- (void)stopReplyUpdates
{
    [updatesLoader stop];
}

#pragma mark - VKRequestExecutorDelegate

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFinishWithObject:(id)value
{
    settings.deviceToken = value ? newToken : nil;
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didFailedWithError:(NSError *)error
{
    newToken = nil;
}

- (void)VKRequestExecutor:(VKRequestExecutor *)executor didAlreadyUpload:(float)progress
{
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController hideStatusBarIfNeed];
}

@end
