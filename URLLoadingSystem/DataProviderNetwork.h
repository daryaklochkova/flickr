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

NS_ASSUME_NONNULL_BEGIN

@interface DataProviderNetwork : NSObject

@property (strong, nonatomic) id<Parser> parser;

- (void)sendRequest:(NSURL *) url;

@end

NS_ASSUME_NONNULL_END
