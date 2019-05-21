//
//  DataProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 20/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "DataProvider.h"

@implementation DataProvider

- (instancetype)initWithParser:(id<Parser>) parser{
    self = [super init];
    
    if (self){
        self.parser = parser;
    }
    
    return self;
}

- (id <Request>)GetRequestGetGalleries:(NSString * _Nullable)userID {
    FlickrRequest *request = [[FlickrRequest alloc] initWithMethod:@"flickr.galleries.getList" andFormat:[self.parser getFormatType]];
    [request addQueryItem:@"user_id" value:userID];
    [request addQueryItem:@"continuation" value:@"0"];
    [request addQueryItem:@"short_limit" value:@"1"];
    [request addQueryItem:@"per_page" value:@"1"];
    [request addQueryItem:@"page" value:@"10"];
    return request;
}


- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler{
    id <Request> request = [self GetRequestGetGalleries:userID];
    
    self.parser.responseParser = [[GetListOfGalleriesResponseParser alloc] initWith:completionHandler];
    
    [self sendRequest:request.URL];
}


- (void)getPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler{
    id <Request> request = [self GetRequest:galleryID];
    self.parser.responseParser = [[GetPhotosResponseParser alloc] initWith:completionHandler];
    [self sendRequest:request.URL];
}


- (id <Request>)GetRequest:(NSString * _Nullable)galleryID {
    FlickrRequest *request = [[FlickrRequest alloc] initWithMethod:@"flickr.galleries.getPhotos" andFormat:[self.parser getFormatType]];
    [request addQueryItem:@"gallery_id" value:galleryID];
    
    return request;
}

@end
