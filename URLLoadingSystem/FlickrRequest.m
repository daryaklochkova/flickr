//
//  NetworkRequest.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "FlickrRequest.h"

@implementation FlickrRequest

- (instancetype)initWithMethod:(NSString *)method{
    self = [super init];
    
    if (self) {
        _serverURL = [NSURL URLWithString:@"https://www.flickr.com/services/rest/"];
        _apiKey = @"85974c3f3e4f62fd98efb4422277c008";
        _method = method;
    }
    
    return self;
}

- (NSURL *)createRequest{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self.serverURL resolvingAgainstBaseURL:NO];
    NSURLQueryItem *method = [NSURLQueryItem queryItemWithName:@"method" value:self.method];
    NSURLQueryItem *apiKey = [NSURLQueryItem queryItemWithName:@"api_key" value:self.apiKey];
    
    urlComponents.queryItems = @[method, apiKey];
    
    return urlComponents.URL;
}

@end
