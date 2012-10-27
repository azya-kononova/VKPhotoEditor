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

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

NSString *VKErrorDomain = @"VKErrorDomain";

@implementation VKConnectionService
@synthesize rootURL;
@synthesize account;

+ (VKConnectionService*)shared
{
    return [AppDelegate shared].connectionService;
}

- (id)initWithURL:(NSURL*)url
{
    if (self = [super init]) {
        rootURL = url;
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

- (VKRequestExecutor*)login:(NSString*)login
{
    RequestExecutorProxy *exec = [self getPath:[NSString stringWithFormat:@"login?login=%@&password=%@", login, [[self getMacAddress] md5]]];
    exec.onSuccess = @selector(exec:didLogin:);
    return exec;
}

- (VKRequestExecutor*)uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            photo, @"file",
                            caption, @"caption",
                            account.accessToken, @"access_token", nil];
    RequestExecutorProxy *exec = [self postToPath:@"uploadPhoto" params:[[WebParams alloc] initWithDictionary:params] json:NO];
    return exec;
}

- (void)exec:(VKRequestExecutor*)exec didLogin:(id)data
{
    account = [UserAccount accountWithDict:[data objectForKey:@"credentials"]];
    NSDictionary *user = [[data objectForKey:@"users"] objectAtIndex:0];
    account.login = [user objectForKey:@"login"];
    account.lastPhotos = [[data objectForKey:@"photos"] map:^id(NSDictionary *dict) { return [VKPhoto VKPhotoWithDict:dict]; }];
    NSLog(@"%@",account);
}

- (void)exec:(VKRequestExecutor*)exec didFailWithError:(id)error
{
    
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
