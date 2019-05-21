//
//  DataProviderNetwork.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "ParserProtocol.h"
#import "FlickrRequest.h"
#import "Photo.h"


NS_ASSUME_NONNULL_BEGIN

@interface DataProviderNetwork : NSObject

@property (strong, nonatomic) id<Parser> parser;

- (void)sendRequest:(NSURL *) url;
- (void)cancelDownloadTasksByURL:(NSURL *) url;
- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification;

@end

NS_ASSUME_NONNULL_END
