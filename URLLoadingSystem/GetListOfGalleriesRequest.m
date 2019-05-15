//
//  GetListOfGalleriesRequest.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetListOfGalleriesRequest.h"

@implementation GetListOfGalleriesRequest

- (instancetype)initWithUserID:(NSString *) userID{
    self = [super initWithMethod:@"flickr.galleries.getList"];
    
    if (self) {
        _userID = userID;
        _continuation = @"0";
        _shortLimit = @"1";
    }
    
    return self;
}

- (NSURL *)createRequest{
    NSURL *url = [super createRequest];
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSURLQueryItem *userID = [NSURLQueryItem queryItemWithName:@"user_id" value:self.userID];
    NSURLQueryItem *continuation = [NSURLQueryItem queryItemWithName:@"continuation" value:self.continuation];
    NSURLQueryItem *shortLimit = [NSURLQueryItem queryItemWithName:@"short_limit" value:self.shortLimit];
    
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:urlComponents.queryItems];
    [queryItems addObject:userID];
    [queryItems addObject:continuation];
    [queryItems addObject:shortLimit];
    urlComponents.queryItems = queryItems;
    
    return urlComponents.URL;
}

@end
