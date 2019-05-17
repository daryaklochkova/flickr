//
//  DataProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "FlickrRequest.h"
#import "GetPhotosResponseParser.h"
#import "GetListOfGalleriesResponseParser.h"


@protocol DataProviderProtocol <NSObject>

- (instancetype)initWithParser:(id<Parser>) parser;
- (void)getPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler;
- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DataProvider : NSObject <DataProviderProtocol>

@end

NS_ASSUME_NONNULL_END
