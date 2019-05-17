//
//  PhotoProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProviderNetwork.h"
#import "GetPhotosResponseParser.h"


NS_ASSUME_NONNULL_BEGIN

@protocol PhotoProviderProtocol

- (void)getPhotosForGallery:(NSString * _Nullable)galleryID use:(ReturnResult _Nullable) completionHandler;
- (instancetype)initWithParser:(id<Parser>) parser;

@end

@interface PhotoProvider : DataProviderNetwork <PhotoProviderProtocol>

@end

NS_ASSUME_NONNULL_END
