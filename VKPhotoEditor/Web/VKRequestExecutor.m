//
//  VKRequestExecutor.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "VKRequestExecutor.h"
#import "VKConnectionService.h"
#import "JSONKit.h"
#import "NSDictionary+Helpers.h"
#import "Settings.h"

@protocol RequestExecutor_NSURLConnectionHandler
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end

NSString *VKRequestExecutorErrorDomain = @"VKError";

@interface NSURLConnectionHandlerProxy : NSObject <RequestExecutor_NSURLConnectionHandler>
@property (nonatomic, assign) id<RequestExecutor_NSURLConnectionHandler> delegate;
@end

@interface VKRequestExecutor () <RequestExecutor_NSURLConnectionHandler>
@end

@implementation VKRequestExecutor {
    NSURLConnection *connection;
    NSURLConnectionHandlerProxy *proxy;
    NSMutableData *data;
}
@synthesize delegate;
@synthesize request;
@synthesize isFinished;

- (id)initWithRequest:(NSURLRequest*)_request
{
    if (self = [super init]) {
        request = _request;
        NSAssert(request, @"VKRequestExecutor should be created with request");
        proxy = [NSURLConnectionHandlerProxy new];
        proxy.delegate = self;
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:proxy startImmediately:NO];
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)start
{
    if (isFinished) {
        data = nil;
        [connection cancel];
        connection = nil;
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:proxy];
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        isFinished = NO;
    } else {
      [connection start];  
    }
}


- (void)stop
{
    [connection cancel];
}

- (void)dealloc
{
    proxy.delegate = nil;
    [self stop];
}

- (void)_notifyError:(NSError*)error
{
    [delegate VKRequestExecutor:self didFailedWithError:error];
}

- (NSError*)errorWithMessage:(NSString*)message code:(NSInteger)code reason:(NSString*)reason;
{
    NSString *description = [[Settings current] descriptionForErrorKey:message];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          description ? description : message, NSLocalizedDescriptionKey,
                          reason, NSLocalizedFailureReasonErrorKey,
                          nil];
    return [NSError errorWithDomain:VKRequestExecutorErrorDomain code:code userInfo:info];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    if (!data) {
        data = [[NSMutableData alloc] initWithData:_data];
    } else {
        [data appendData:_data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#if DEBUG
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!text.length) text = [[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding];
    NSLog(@"Response for %@\n%@", request, text);
#endif
    isFinished = YES;
    JSONDecoder *jsonDecoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    id obj = [jsonDecoder objectWithData:data];
    if (!obj) {
        [self _notifyError:[self errorWithMessage:@"Неверный формат ответа от сервера." code:0 reason:nil]];
        return;
    }
    if ([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"error"]) {
        NSDictionary *error = [obj objectForKey:@"error"];
        [self _notifyError:[self errorWithMessage:[error objectForKey:@"type"] code:[error integerForKey:@"code"] reason:@"Server error"]];
        return;
    }
    [delegate VKRequestExecutor:self didFinishWithObject:[obj objectForKey:@"response"]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    isFinished = YES;
    [self _notifyError:error];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
     [delegate VKRequestExecutor:self didAlreadyUpload:(float) totalBytesWritten / (float) totalBytesExpectedToWrite];
}

@end


@implementation NSURLConnectionHandlerProxy
@synthesize delegate;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [delegate connection:connection didReceiveData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [delegate connectionDidFinishLoading:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [delegate connection:connection didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}
@end
