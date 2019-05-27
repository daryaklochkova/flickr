//
//  DataProviderNetwork.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "DataProviderNetwork.h"

const NSNotificationName dataFetchError = @"dataFetchError";
const NSNotificationName downloadFileError = @"downloadFileError";

@interface DataProviderNetwork()
@property (strong, nonatomic) NSMutableArray *activeTasks;
@end

@implementation DataProviderNetwork

-(instancetype)init{
    self = [super init];
    
    if (self){
        self.activeTasks = [NSMutableArray array];
        self.continuation = [continuationStartValue copy];
    }
    
    return self;
}

- (void)sendRequest:(NSDictionary *) requestFields{
    
    failBlock failBlock = ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *notificationInfo = @{errorKey:error};
            [[NSNotificationCenter defaultCenter] postNotificationName:dataFetchError object:notificationInfo];
        });
    };
    
    NetworkManager *networkManager = [NetworkManager defaultManager];
    NSURLRequest *request = [networkManager createRequestWithDictionary:requestFields];
    
    [networkManager fetchData:request parseResponceWith:self.parser using:^(NSData * _Nullable responseData){} and:failBlock];
}


- (void)cancelTasksByURL:(NSURL *) url{
    [[NetworkManager defaultManager] cancelDownloadTasksWithUrl:url];
}


- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification {
    
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
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:downloadFileError object:nil];
        }
    };
    
    [[NetworkManager defaultManager] downloadData:[NSURLRequest requestWithURL:remoteURL] using:completionHandler and:failBlock];
}

- (BOOL)continuationExist{
    return ![self.continuation isEqualToString:[continuationEndValue copy]];
}

- (ReturnResultWithContinuation)createReturnResultWithContinuationWith:(ReturnResult)returnResultBlock{
    __weak typeof(self) weakSelf = self;
    ReturnResultWithContinuation block = ^(NSArray * _Nullable result, NSString *continuation) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.continuation = continuation;
        returnResultBlock(result);
    };
    
    return block;
}

@end
