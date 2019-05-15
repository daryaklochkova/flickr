//
//  GetPhotosFromGalleruRequest.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetPhotosFromGalleryRequest.h"

@implementation GetPhotosFromGalleryRequest

- (instancetype)initWithGalleryID:(NSString *) galleryID{
    self = [super initWithMethod:@"flickr.galleries.getPhotos"];
    
    if (self) {
        _galleryID = galleryID;
    }
    
    return self;
}

- (NSURL *)createRequest{
    NSURL *url = [super createRequest];
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSURLQueryItem *galleryID = [NSURLQueryItem queryItemWithName:@"gallery_id" value:self.galleryID];
    //NSURLQueryItem *page = [NSURLQueryItem queryItemWithName:@"page" value:[NSString stringWithFormat:@"%ld", (long)self.nextPage]];
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:urlComponents.queryItems];
    [queryItems addObject:galleryID];
    urlComponents.queryItems = queryItems;
    
    return urlComponents.URL;
}

@end
