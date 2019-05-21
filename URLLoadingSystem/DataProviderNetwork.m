//
//  DataProviderNetwork.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "DataProviderNetwork.h"

@interface DataProviderNetwork()
@property (strong, nonatomic) NSMutableArray *activeTasks;
@end

@implementation DataProviderNetwork

-(instancetype)init{
    self = [super init];
    
    if (self){
        self.activeTasks = [NSMutableArray array];
    }
    
    return self;
}

- (void)sendRequest:(NSURL *) url{
    
    SessionDataTaskCallBack completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.parser parse:data];
            });
        }
    };
     [[NetworkManager defaultManager] fetchDataFromURL:url using:completionHandler];
}


- (void)cancelDownloadTasksByURL:(NSURL *) url{
    [[NetworkManager defaultManager] cancelDownloadTasksWithUrl:url];
}


- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification{
    
    SessionDownloadTaskCallBack completionHandler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSError *err = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (location && [fileManager copyItemAtURL: location toURL: localFileURL error: &err]) {
            
            dispatch_async(dispatch_get_main_queue(),^{
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
        }
        else {
            NSLog(@"error - %@", err);
        }
    };
    
    [[NetworkManager defaultManager] downloadData:remoteURL using:completionHandler];
}

@end
