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

@protocol Request <NSObject>

@property (strong, nonatomic, readonly) NSURL *URL;//readonly
@property (strong, nonatomic, readonly) NSString *method;
@property (strong, nonatomic, readonly) NSURL *serverURL;

//dictionary parametrs 
@end


@interface FlickrRequest : NSObject <Request>


@property (strong, nonatomic, readonly) NSString *apiKey;


- (instancetype)initWithMethod:(NSString *)method andFormat:(Format) format;
- (void)addQueryItem:(NSString *) name value:(NSString *) value;

@end

NS_ASSUME_NONNULL_END
