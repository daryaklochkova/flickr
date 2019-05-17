//
//  DataProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "DataProvider.h"

@interface DataProvider()

@property (strong, nonatomic) id<Parser> parser;

@end

@implementation DataProvider


- (instancetype)initWithParser:(id<Parser>) parser{
    self = [super init];
    
    if (self){
        self.parser = parser;
    }
    
    return self;
}

- (void)getPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler{
    FlickrRequest *request = [[FlickrRequest alloc] initWithMethod:@"flickr.galleries.getPhotos" andFormat:[self.parser getFormatType]];
    [request addQueryItem:@"gallery_id" value:galleryID];
    
    self.parser.responseParser = [[GetPhotosResponseParser alloc] initWith:completionHandler];
    
    [self sendRequest:request.URL];
}

- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler{
    FlickrRequest *request = [[FlickrRequest alloc] initWithMethod:@"flickr.galleries.getList" andFormat:[self.parser getFormatType]];
    [request addQueryItem:@"user_id" value:userID];
    [request addQueryItem:@"continuation" value:@"0"];
    [request addQueryItem:@"short_limit" value:@"1"];
    
    self.parser.responseParser = [[GetListOfGalleriesResponseParser alloc] initWith:completionHandler];
    
    [self sendRequest:request.URL];
}

- (void)sendRequest:(NSURL *) url{
    NetworkManager *networkManager = [NetworkManager defaultNetworkManager];
    
    SessionDataTaskCallBack completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.parser parse:data];
        });
    };
    
    [networkManager fetchDataFromURL:url using:completionHandler];
}

@end
