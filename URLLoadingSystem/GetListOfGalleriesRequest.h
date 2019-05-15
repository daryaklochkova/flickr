//
//  GetListOfGalleriesRequest.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "FlickrRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GetListOfGalleriesRequest : FlickrRequest

@property (strong, nonatomic, readonly) NSString *userID;
@property (strong, nonatomic, readonly) NSString *continuation;
@property (strong, nonatomic, readonly) NSString *shortLimit;

- (instancetype)initWithUserID:(NSString *) userID;
@end

NS_ASSUME_NONNULL_END
