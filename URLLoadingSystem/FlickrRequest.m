//
//  NetworkRequest.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "FlickrRequest.h"

@interface FlickrRequest()
@property (strong, nonatomic) NSURL *URL;//readonly
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSURL *serverURL;

@end

@implementation FlickrRequest
@synthesize URL;

- (instancetype)initWithMethod:(NSString *)method andFormat:(Format) format{
    self = [super init];
    
    if (self) {
        _serverURL = [NSURL URLWithString:@"https://www.flickr.com/services/rest/"];
        _apiKey = @"85974c3f3e4f62fd98efb4422277c008";
        _method = method;
        self.URL = [self createRequestWithFormat:format];
    }
    
    return self;
}

- (NSURL *)createRequestWithFormat:(Format) format{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self.serverURL resolvingAgainstBaseURL:NO];
    NSURLQueryItem *method = [NSURLQueryItem queryItemWithName:@"method" value:self.method];
    NSURLQueryItem *apiKey = [NSURLQueryItem queryItemWithName:@"api_key" value:self.apiKey];
    NSURLQueryItem *formatItem = [NSURLQueryItem queryItemWithName:@"format" value: [self formatToNSString:format]];
    
    NSURLQueryItem *nojsoncallback = [[NSURLQueryItem alloc] init];
    if (format == JSONFormat){
        nojsoncallback = [NSURLQueryItem queryItemWithName:@"nojsoncallback" value:@"1"];
    }
    
    urlComponents.queryItems = @[method, apiKey, formatItem, nojsoncallback];
    
    return urlComponents.URL;
}

- (void)addQueryItem:(NSString *) name value:(NSString *) value{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self.URL resolvingAgainstBaseURL:NO];
    NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:name value:value];

    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:urlComponents.queryItems];
    [queryItems addObject:item];
    
    urlComponents.queryItems = queryItems;
    
    self.URL = urlComponents.URL;
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
