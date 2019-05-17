//
//  PhotoProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoProvider.h"

@implementation PhotoProvider

- (instancetype)initWithParser:(id<Parser>) parser{
    self = [super init];
    
    if (self){
        self.parser = parser;
    }
    
    return self;
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
