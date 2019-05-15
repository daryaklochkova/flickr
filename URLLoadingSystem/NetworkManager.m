//
//  SessionDelegate.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

+ (instancetype) defaultNetworkManager {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


- (instancetype)init{
    self = [super init];
    
    if (self) {
        [self createConnection];
    }
    
    return self;
}


- (void)createConnection{
    NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:@"MyCache"];
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
    defaultConfiguration.URLCache = cache;
    defaultConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
    
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:operationQueue];
}


- (void)fetchDataFromURL:(NSURL *) url using:(SessionDataTaskCallBack) completionHandler{
    [[self.defaultSession dataTaskWithURL:url completionHandler:completionHandler] resume];
}


- (void) downloadData:(NSURL *) url using:(SessionDownloadTaskCallBack) completionHandler{
    [[self.defaultSession downloadTaskWithURL:url completionHandler:completionHandler] resume];
}


@end
