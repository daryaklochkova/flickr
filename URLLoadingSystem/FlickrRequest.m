//
//  NetworkRequest.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "FlickrRequest.h"

@implementation FlickrRequest

- (instancetype)initWithMethod:(NSString *)method and:(Format)format{
    self = [super init];
    
    if (self) {
        _serverURL = [NSURL URLWithString:@"https://www.flickr.com/services/rest/"];
        _apiKey = @"85974c3f3e4f62fd98efb4422277c008";
        _method = method;
        _format = format;
    }
    
    return self;
}

- (NSURL *)createRequest{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self.serverURL resolvingAgainstBaseURL:NO];
    NSURLQueryItem *method = [NSURLQueryItem queryItemWithName:@"method" value:self.method];
    NSURLQueryItem *apiKey = [NSURLQueryItem queryItemWithName:@"api_key" value:self.apiKey];
    NSURLQueryItem *format = [NSURLQueryItem queryItemWithName:@"format" value: [self formatToNSString:self.format]];
    
    NSURLQueryItem *nojsoncallback = [[NSURLQueryItem alloc] init];
    if (self.format == JSONFormat){
        nojsoncallback = [NSURLQueryItem queryItemWithName:@"nojsoncallback" value:@"1"];
    }
    
    urlComponents.queryItems = @[method, apiKey, format, nojsoncallback];
    
    return urlComponents.URL;
}

- (NSString *)formatToNSString:(Format) format{
    switch (format) {
        case JSONFormat:
            return @"json";
            break;
        case XMLFormat:
            return @"rest";
            break;
        default:
            return nil;
            break;
    }
}

@end
