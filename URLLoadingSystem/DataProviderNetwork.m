//
//  DataProviderNetwork.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "DataProviderNetwork.h"

@implementation DataProviderNetwork


- (void)sendRequest:(NSURL *) url{
    NetworkManager *networkManager = [NetworkManager defaultManager];
    
    SessionDataTaskCallBack completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.parser parse:data];
        });
    };
    
    [networkManager fetchDataFromURL:url using:completionHandler];
}


@end
