//
//  NetworkRequest.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "ParserProtocol.h"
#import "ResponseParser.h"

NS_ASSUME_NONNULL_BEGIN


@interface FlickrRequest : NSObject

@property (strong, nonatomic, readonly) NSURL *serverURL;
@property (strong, nonatomic, readonly) NSString *apiKey;
@property (strong, nonatomic, readonly) NSString *method;

@property (strong, nonatomic, readonly) NSURL *URL;


- (instancetype)initWithMethod:(NSString *)method andFormat:(Format) format;
- (void)addQueryItem:(NSString *) name value:(NSString *) value;

@end

NS_ASSUME_NONNULL_END
