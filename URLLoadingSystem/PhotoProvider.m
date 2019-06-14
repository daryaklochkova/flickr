//
//  PhotoProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 22/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoProvider.h"
#import "ParserProvider.h"
#import "GetPhotosResponseParser.h"


@implementation PhotoProvider

- (instancetype)init{
    self = [super init];
    
    if (self){
        self.parser = [[ParserProvider defaultProvider] getParser];
    }
    
    return self;
}

- (void)getPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler {
    self.continuation = [continuationStartValue copy];
    [self getAdditionalPhotosForGallery:galleryID use:completionHandler];
    
}

- (void)getAdditionalPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler{
    if ([self continuationExist]){
        ReturnResultWithContinuation returnBlock = [self createReturnResultWithContinuationWith:completionHandler];
        self.parser.responseParser = [[GetPhotosResponseParser alloc] initWith:returnBlock];
        [self sendRequest:[self GetRequestFields:galleryID]];
    }
    else {
        NSLog(@"continuation doesn't exist");
    }
}

- (void)savePhotos:(nonnull NSArray *)images forGalleryID:(nonnull NSString *)gallery byPath:(nonnull NSString *)path {
    
}


- (void)savePrimaryPhoto:(id)image forGalleryID:(nonnull NSString *)galleryID byPath:(nonnull NSString *)path {
    
}



- (NSDictionary *)GetRequestFields:(NSString *)galleryID {

    NSDictionary *requestFields = @{
                                    methodArgumentName:         getGalleriesGetPhotoMethod,
                                    formatArgumentName:         [self.parser getStringFormatType],
                                    galleryIDArgumentName:      galleryID,
                                    continuationArgumentName:   self.continuation
                                    };
    return requestFields;
}

@end
