//
//  NetworkRequest.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "JSONParser.h"
#import "XMLParser.h"
#import "ResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    JSONFormat,
    XMLFormat
} Format;

@interface FlickrRequest : NSObject

@property (strong, nonatomic, readonly) NSURL *serverURL;
@property (strong, nonatomic, readonly) NSString *apiKey;
@property (strong, nonatomic, readonly) NSString *method;
@property (assign, nonatomic, readonly) Format format;
@property (strong, nonatomic) id<ResponseParser> responseParser;


- (instancetype)initWithMethod:(NSString *)method;
- (NSURL *)createRequest;
- (void)sendRequest;
@end

NS_ASSUME_NONNULL_END
