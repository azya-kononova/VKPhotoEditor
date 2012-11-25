//
//  VKConnectionService.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKConnectionService.h"
#import "AppDelegate.h"
#import "WebParams.h"
#import "RequestExecutorProxy.h"
#import "NSString+MD5.h"
#import "NSObject+Map.h"
#import "VKPhoto.h"
#import "Settings.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

NSString *VKErrorDomain = @"VKErrorDomain";
NSString *VKRequestDidFailNotification = @"VKRequestDidFail";

@implementation VKConnectionService
@synthesize rootURL;
@synthesize profile;

+ (VKConnectionService*)shared
{
    return [AppDelegate shared].connectionService;
}

- (id)initWithURL:(NSURL*)url
{
    if (self = [super init]) {
        rootURL = url;
        profile = [Settings current].profile;
    }
    return self;
}

- (NSMutableURLRequest*)getRequestForPath:(NSString*)path
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:rootURL];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setMainDocumentURL:rootURL];
    
#if DEBUG_NETWORKING
    NSLog(@"Request: %@ Cookies: %@", req, self.cookies);
#endif
    return req;
}

- (NSMutableURLRequest*)requestForPath:(NSString*)path params:(WebParams*)params json:(BOOL)json
{
    NSData *data = json ? params.jsonData : params.postData;
    NSString *contentType = json ? params.jsonContentType : params.postContentType;
    NSMutableURLRequest *req = [self getRequestForPath:path];
    req.HTTPBody = data;
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    return req;
}

- (RequestExecutorProxy*)executorForRequest:(NSURLRequest*)req
{
    RequestExecutorProxy *proxy = [[RequestExecutorProxy alloc] initWithRequest:req];
    proxy.target = self;
    proxy.onError = @selector(exec:didFailWithError:);
    return proxy;
}

- (RequestExecutorProxy*)getPath:(NSString*)path
{
    return [self executorForRequest:[self getRequestForPath:path]];
}

- (RequestExecutorProxy*)postToPath:(NSString*)path params:(WebParams*)params json:(BOOL)json
{
    NSMutableURLRequest *req = [self requestForPath:path params:params json:json];
    req.HTTPMethod = @"POST";
    return [self executorForRequest:req];
}

- (RequestExecutorProxy*)deleteToPath:(NSString*)path params:(WebParams*)params json:(BOOL)json
{
    NSMutableURLRequest *req = [self requestForPath:path params:params json:json];
    req.HTTPMethod = @"DELETE";
    return [self executorForRequest:req];
}

- (RequestExecutorProxy*)putToPath:(NSString*)path params:(WebParams*)params json:(BOOL)json
{
    NSMutableURLRequest *req = [self requestForPath:path params:params json:json];
    req.HTTPMethod = @"PUT";
    return [self executorForRequest:req];
}

- (void)logout
{
    [Settings current].profile = nil;
}

#pragma mark - api methods

- (VKRequestExecutor*)login:(NSString*)login
{
    RequestExecutorProxy *exec = [self getPath:[NSString stringWithFormat:@"login?login=%@&password=%@", login, [[self getMacAddress] md5]]];
    exec.onError = nil;
    exec.onSuccess = @selector(exec:didLogin:);
    return exec;
}

- (VKRequestExecutor*)uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            photo, @"file",
                            caption, @"caption",
                            profile.accessToken, @"access_token", nil];
    RequestExecutorProxy *exec = [self postToPath:@"uploadPhoto" params:[[WebParams alloc] initWithDictionary:params] json:NO];
    if (caption.length >= 3 && [[caption substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"#me"]) exec.onSuccess = @selector(exec:didLoadAvatar:);
    return exec;
}

- (VKRequestExecutor*)deletePhoto:(NSString*)photoId
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            photoId, @"id",
                            profile.accessToken, @"access_token", nil];
    RequestExecutorProxy *exec = [self postToPath:@"deletePhotos" params:[[WebParams alloc] initWithDictionary:params] json:NO];
    if ([photoId isEqualToString:profile.avatarId]) exec.onSuccess = @selector(exec:didDeleteAvatar:);
    return exec;
}

- (VKRequestExecutor*)getPhotos:(NSInteger)userId offset:(NSInteger)offset limit:(NSInteger)limit
{
    RequestExecutorProxy *exec = [self getPath:[NSString stringWithFormat:@"getPhotos?user_id=%d&offset=%d&limit=%d", userId, offset, limit]];
    return exec;
}

- (VKRequestExecutor*)searchPhotos:(NSString*)query offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSString *path = [NSString stringWithFormat:@"searchPhotos?offset=%d&limit=%d", offset, limit];
    if (query.length) {
        path = [path stringByAppendingFormat:@"&q=%@", [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    RequestExecutorProxy *exec = [self getPath:path];
    return exec;
}

#pragma mark - executors handlers

- (void)exec:(VKRequestExecutor*)exec didLogin:(id)data
{
    profile = [UserProfile accountWithDict:[[data objectForKey:@"users"] objectAtIndex:0]];
    profile.accessToken = [[data objectForKey:@"credentials"] objectForKey:@"access_token"];
    
    NSMutableDictionary *accounts = [NSMutableDictionary new];
    for (NSDictionary *user in [data objectForKey:@"users"]) {
        Account *acc = [Account accountWithDict:user];
        [accounts setObject:acc forKey:[user objectForKey:@"id"]];
    }    
    
    profile.lastPhotos = [[data objectForKey:@"photos"] map:^id(NSDictionary *dict) {
        VKPhoto *photo = [VKPhoto VKPhotoWithDict:dict];
        photo.account = [accounts objectForKey:[dict objectForKey:@"user_id"]];
        return photo; }];
    
    [Settings current].profile = profile;
}

- (void)exec:(VKRequestExecutor*)exec didLoadAvatar:(id)data
{
    NSDictionary *user = [[data objectForKey:@"users"] objectAtIndex:0];
    profile.avatarUrl = [NSURL URLWithString:[[user objectForKey:@"photo"] objectForKey:@"photo_small"]];
    profile.avatarId = [[data objectForKey:@"photo"] objectForKey:@"id"];
    [Settings current].profile = profile;
}

- (void)exec:(VKRequestExecutor*)exec didDeleteAvatar:(id)data
{
    profile.avatarUrl = nil;
    profile.avatarId = nil;
    [Settings current].profile = profile;
}

- (void)exec:(VKRequestExecutor*)exec didFailWithError:(id)error
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"Error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:VKRequestDidFailNotification object:self userInfo:userInfo];
}

- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else {
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else {
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else {
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    if (errorFlag != NULL) {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    free(msgBuffer);
    return macAddressString;
}


@end
