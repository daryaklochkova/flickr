//
//  NetworkRequest.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    JSONFormat,
    XMLFormat
} Format;

@interface FlickrRequest : NSObject

@property (strong, nonatomic, readonly) NSURL *serverURL;
@property (strong, nonatomic, readonly) NSString *apiKey;
@property (strong, nonatomic, readonly) NSString *method;
@property (assign, nonatomic, readonly) Format *format;


- (instancetype)initWithMethod:(NSString *)method and:(Format) format;
- (NSURL *)createRequest;

@end

NS_ASSUME_NONNULL_END
