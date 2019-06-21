//
//  SessionDelegate.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "NetworkManager.h"


@implementation NetworkManager

+ (instancetype) defaultManager {
    static dispatch_once_t once = 0;
    static id _sharedObject = nil;
    dispatch_once(&once, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self createConnection];
    }
    
    return self;
}

- (void)createConnection {
    NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:@"MyCache"];
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
    defaultConfiguration.URLCache = cache;
    defaultConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    
    NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
    
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:operationQueue];
}


- (NSURLSessionTask *)fetchData:(NSURLRequest *) request
                            parseResponceWith:(id<Parser>)parser
                            using:(successDataTaskBlock) succcessBlock
                            and:(failBlock) failBlock {
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        //error = [[NSError alloc] init];
        if (error) {
            NSURLCache *cache = strongSelf.defaultSession.configuration.URLCache;
            NSCachedURLResponse *cachedResponce = [cache cachedResponseForRequest:request];
            
            if (cachedResponce) {
                __weak id<Parser> weakParser = parser;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    __strong id<Parser> strongParser = weakParser;
                    [strongParser parse:cachedResponce.data];
                });
                succcessBlock(cachedResponce.data);
            }
            else {
                failBlock(error);
                NSLog (@"NetworkManager fetch data failed - %@", [error description]);
            }
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [parser parse:data];
            });
            succcessBlock(data);
        }
    }];
    
    [task resume];
    
    return task;
}


- (NSURLSessionTask *)downloadData:(NSURLRequest *)request
                             using:(successDownloadTaskBlock)successBlock
                               and:(failBlock)failBlock {
    
    NSURLSessionTask *task = [self.defaultSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //error = [[NSError alloc] init];
        if (error) {
            failBlock(error);
            NSLog (@"NetworkManager download data failed - %@", [error description]);
        }
        else {
            successBlock(location);
        }
    }];
    [task resume];
    return task;
}

- (void)cancelDownloadTasksWithUrl:(NSURL *)url{ //NSOperationQueue?
    [self.defaultSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            if ([downloadTask.originalRequest.URL isEqual:url]){
                [downloadTask cancel];
            }
        }
    }];
}

- (void)cancelDataTasksWithUrl:(NSURL *)url{
    [self.defaultSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        for (NSURLSessionDataTask *task in dataTasks) {
            if ([task.originalRequest.URL isEqual:url]){
                [task cancel];
            }
        }
    }];
}

- (NSURLRequest *)createRequestWithDictionary:(NSDictionary<NSString *, NSString *> *)requestFields{
    NSURLComponents *urlComponents  = [NSURLComponents componentsWithString:[baseURL copy]];
    
    NSURLQueryItem *apiKeyItem = [NSURLQueryItem queryItemWithName:[apiKey copy] value:[apiKeyValue copy]];
    NSMutableArray<NSURLQueryItem *> *queryItems = [[NSMutableArray alloc] init];
    [queryItems addObject:apiKeyItem];
    
    for (NSString *key in requestFields) {
        NSString *value = [requestFields objectForKey:key];
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
        [queryItems addObject:item];
    }
    
    NSString *format = [requestFields objectForKey:[formatArgumentName copy]];
    if ([format isEqualToString:@"json"]) {
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:@"nojsoncallback" value:@"1"];
        [queryItems addObject:item];
    }
    
    urlComponents.queryItems = queryItems;
    return [NSURLRequest requestWithURL:urlComponents.URL];
}


@end
