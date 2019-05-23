//
//  DataProviderNetwork.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "DataProviderNetwork.h"

const NSNotificationName dataFetchError = @"dataFetchError";
const NSString *errorKey = @"errorKey";


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

- (void)sendRequest:(NSDictionary *) requestFields{
    
    __weak typeof(self) weakSelf = self;
    successDataTaskBlock successCompletionHandler = ^(NSData *responseData) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [strongSelf.parser parse:responseData];
        });
    };
    
    NetworkManager *networkManager = [NetworkManager defaultManager];
    NSURLRequest *request = [networkManager createRequestWithDictionary:requestFields];
    [networkManager fetchData:request using:successCompletionHandler and:^(NSError *error) {
        //NSLog(@"%@ failed with error - %@", request.URL, error);
        NSDictionary *notificationInfo = @{errorKey:error};
        [[NSNotificationCenter defaultCenter] postNotificationName:dataFetchError object:notificationInfo];
    }];
}


- (void)cancelDownloadTasksByURL:(NSURL *) url{
    [[NetworkManager defaultManager] cancelDownloadTasksWithUrl:url];
}


- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification{
    
    successDownloadTaskBlock completionHandler = ^(NSURL * _Nullable location) {
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
    
    failBlock failBlock =^(NSError * _Nullable error) {
        
        NSString *path = localFileURL.absoluteString;

        if ([[NSFileManager defaultManager] fileExistsAtPath:[path substringFromIndex:6]]){
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    };
    
    [[NetworkManager defaultManager] downloadData:[NSURLRequest requestWithURL:remoteURL] using:completionHandler and:failBlock];
}

@end
