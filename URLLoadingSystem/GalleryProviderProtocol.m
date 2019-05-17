//
//  GalleryProviderProtocol.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryProviderProtocol.h"

@interface GalleryProvider()

@property (strong, nonatomic) NSString *userID;

@end

@implementation GalleryProvider

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
    return request;
}


- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler{
    id <Request> request = [self GetRequestGetGalleries:userID];
    
    self.parser.responseParser = [[GetListOfGalleriesResponseParser alloc] initWith:completionHandler];
    
    [self sendRequest:request.URL];
}


- (void)cancelTaskForUser:(NSString * _Nullable)userID {
    id <Request> request = [self GetRequestGetGalleries:userID];
    [[NetworkManager defaultManager] cancelDataTasksWithUrl:request.URL];
}

@end
