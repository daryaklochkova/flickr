//
//  PhotoProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 22/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoProvider.h"

@implementation PhotoProvider

- (instancetype)init{
    self = [super init];
    
    if (self){
        self.parser = [[XMLParser alloc] init];
    }
    
    return self;
}


- (void)getPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler{
    self.parser.responseParser = [[GetPhotosResponseParser alloc] initWith:completionHandler];
    [self sendRequest:[self GetRequestFields:galleryID]];
}

- (void)cancelTasksByURL:(nonnull NSURL *)url {
    
}



- (NSDictionary *)GetRequestFields:(NSString *)galleryID {

    NSDictionary *requestFields = @{
                                    @"flickr.galleries.getPhotos":[self.parser getStringFormatType],
                                    @"gallery_id": galleryID
                                    };

    return requestFields;
}

@end
