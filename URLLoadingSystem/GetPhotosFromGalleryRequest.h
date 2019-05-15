//
//  GetPhotosFromGalleruRequest.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "FlickrRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GetPhotosFromGalleryRequest : FlickrRequest

@property (strong, nonatomic, readonly) NSString *galleryID;

- (instancetype)initWithGalleryID:(NSString *) galleryID;
@end

NS_ASSUME_NONNULL_END
